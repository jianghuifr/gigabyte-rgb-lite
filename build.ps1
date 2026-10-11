# GccLite 构建脚本
#
#   .\build.ps1
#
# 只用 Windows 自带的 csc.exe（.NET Framework 4.x），不需要任何 SDK。
# 产物：dist\GccLiteAll.exe（控制台版）和 dist\GccLiteHidden.exe（无窗口版，计划任务用）

$ErrorActionPreference = 'Stop'

$repo = $PSScriptRoot
$src  = Join-Path $repo 'src\GccLiteAll.cs'
$dist = Join-Path $repo 'dist'

$csc = "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if (-not (Test-Path $csc)) {
    # 32 位系统 / 非标准路径的回退
    $csc = "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319\csc.exe"
}
if (-not (Test-Path $csc)) { throw "找不到 csc.exe，请确认已安装 .NET Framework 4.x" }
if (-not (Test-Path $src)) { throw "找不到源码 $src" }

New-Item -ItemType Directory -Force -Path $dist | Out-Null

Write-Host "编译器: $csc"
Write-Host "源码  : $src"
Write-Host ''

$common = @('/nologo', '/platform:x64', '/optimize+')

Write-Host '编译控制台版 ...'
& $csc @common /target:exe /out:"$dist\GccLiteAll.exe" $src
if ($LASTEXITCODE -ne 0) { throw '编译失败' }

Write-Host '编译无窗口版 ...'
& $csc @common /target:winexe /out:"$dist\GccLiteHidden.exe" $src
if ($LASTEXITCODE -ne 0) { throw '编译失败' }

Write-Host ''
Get-ChildItem $dist | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize
Write-Host '完成。运行 dist\GccLiteAll.exe list 看看可用灯效。'
