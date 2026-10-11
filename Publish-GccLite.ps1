# Publish-GccLite.ps1 — 建仓库 / 推送 / 发布 Release
#
#   $env:GITHUB_TOKEN = 'ghp_xxx'          # classic token，需要 repo 权限
#   powershell -ExecutionPolicy Bypass -File .\Publish-GccLite.ps1 -Owner jianghuifr -Repo gcc-lite
#
# 不设置 GITHUB_TOKEN 的话，脚本会提示你输入（输入内容不会回显）。
#
# 做三件事：
#   1. 用 API 建仓库（已存在则跳过）
#   2. git push（走 SSH 或 HTTPS，自动判断）
#   3. 建 v1.0.0 release 并上传 GccLiteAll.exe + GccLiteHidden.exe + 源码 zip

param(
    [Parameter(Mandatory = $true)][string]$Owner,
    [string]$Repo = 'gcc-lite',
    [string]$Tag  = 'v1.0.0',
    [switch]$Private,
    [string]$Description = 'Standalone RGB lighting control for Gigabyte Z790M AORUS ELITE - replaces GIGABYTE Control Center'
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$api  = 'https://api.github.com'

# ---------- token ----------
$tok = $env:GITHUB_TOKEN
if (-not $tok) {
    $sec = Read-Host -Prompt 'GitHub Personal Access Token (repo scope)' -AsSecureString
    $tok = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
}
if (-not $tok) { throw '需要 token' }

$headers = @{
    Authorization          = "token $tok"
    Accept                 = 'application/vnd.github+json'
    'User-Agent'           = 'GccLite-publisher'
    'X-GitHub-Api-Version' = '2022-11-28'
}

function Invoke-GH {
    param([string]$Method, [string]$Url, $Body, [string]$ContentType = 'application/json')
    $p = @{ Method = $Method; Uri = $Url; Headers = $headers; TimeoutSec = 120 }
    if ($null -ne $Body) {
        if ($ContentType -eq 'application/json') { $p.Body = ($Body | ConvertTo-Json -Depth 10) }
        else { $p.Body = $Body; $p.ContentType = $ContentType }
    }
    Invoke-RestMethod @p
}

# ---------- 1. 仓库 ----------
Write-Host "[1/4] 检查/创建仓库 $Owner/$Repo ..."
$created = $false
try {
    $r = Invoke-GH GET "$api/repos/$Owner/$Repo"
    Write-Host ("      已存在: " + $r.html_url + "  (private=" + $r.private + ")")
} catch {
    if ($_.Exception.Response.StatusCode.value__ -ne 404) { throw }
    $body = @{ name = $Repo; description = $Description; private = [bool]$Private; has_issues = $true; has_wiki = $false }
    $r = Invoke-GH POST "$api/user/repos" $body
    $created = $true
    Write-Host ("      已创建: " + $r.html_url)
}

# ---------- 2. 编译 + 提交 + 推送 ----------
Write-Host '[2/4] 构建并推送 ...'
& (Join-Path $root 'build.ps1') | Out-Host

Push-Location $root
try {
    if (-not (Test-Path (Join-Path $root '.git'))) {
        & git init -b main | Out-Null
        & git add -A
        & git -c user.name='GccLite' -c user.email='gcc-lite@users.noreply.github.com' commit -m 'GccLite v1.0.0' | Out-Null
    } else {
        & git add -A
        & git -c user.name='GccLite' -c user.email='gcc-lite@users.noreply.github.com' commit -m 'Update' 2>$null | Out-Null
    }

    $remote = "git@github.com:$Owner/$Repo.git"
    & git remote remove origin 2>$null | Out-Null
    & git remote add origin $remote
    Write-Host "      push -> $remote"
    & git push -u origin main
    if ($LASTEXITCODE -ne 0) { throw 'git push 失败（检查 SSH 密钥是否已加到 GitHub）' }
} finally { Pop-Location }

# ---------- 3. Release ----------
Write-Host "[3/4] 创建 release $Tag ..."
$notes = Get-Content (Join-Path $root 'RELEASE_NOTES.md') -Raw
try {
    $rel = Invoke-GH GET "$api/repos/$Owner/$Repo/releases/tags/$Tag"
    Write-Host ("      release 已存在: " + $rel.html_url)
} catch {
    $rel = Invoke-GH POST "$api/repos/$Owner/$Repo/releases" @{
        tag_name         = $Tag
        target_commitish = 'main'
        name             = "GccLite $Tag"
        body             = $notes
        draft            = $false
        prerelease       = $false
    }
    Write-Host ("      已创建: " + $rel.html_url)
}

# ---------- 4. 上传产物 ----------
Write-Host '[4/4] 上传产物 ...'
$assets = @(
    (Join-Path $root 'dist\GccLiteAll.exe'),
    (Join-Path $root 'dist\GccLiteHidden.exe')
)
$zip = Join-Path $env:TEMP 'gcc-lite-source.zip'
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path (Join-Path $root 'src'), (Join-Path $root 'install'), (Join-Path $root 'effects'),
                       (Join-Path $root 'docs'), (Join-Path $root 'tools'),
                       (Join-Path $root 'build.ps1'), (Join-Path $root 'README.md'), (Join-Path $root 'LICENSE') `
                 -DestinationPath $zip
$assets += $zip

foreach ($a in $assets) {
    if (-not (Test-Path $a)) { Write-Host ("      跳过（不存在）: " + $a); continue }
    $name = Split-Path $a -Leaf
    $uploadUrl = ($rel.upload_url -replace '\{.*\}', '') + "?name=$([uri]::EscapeDataString($name))"
    Write-Host ("      上传 $name (" + (Get-Item $a).Length + " B) ...")
    try {
        $res = Invoke-RestMethod -Method Post -Uri $uploadUrl -Headers $headers `
                 -ContentType 'application/octet-stream' -InFile $a -TimeoutSec 300
        Write-Host ("        -> " + $res.browser_download_url)
    } catch {
        Write-Host ("        失败: " + $_.Exception.Message) -ForegroundColor Yellow
    }
}

Write-Host ''
Write-Host '=== 完成 ==='
Write-Host ("  仓库    : https://github.com/$Owner/$Repo")
Write-Host ("  Release : " + $rel.html_url)
Write-Host ''
Write-Host '提示：用完可以把 token 撤销掉 https://github.com/settings/tokens'
