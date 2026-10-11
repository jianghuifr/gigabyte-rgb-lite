# GccLite 构建脚本
#
#   .\build.ps1
#
# 只用 Windows 自带的 csc.exe（.NET Framework 4.x），不需要任何 SDK。
# 产物：dist\GccLiteAll.exe

$ErrorActionPreference = 'Stop'

$repo = $PSScriptRoot
$src  = Join-Path $repo 'src\GccLiteAll.cs'
$dist = Join-Path $repo 'dist'
$out  = Join-Path $dist 'GccLiteAll.exe'

$csc = "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if (-not (Test-Path $csc)) {
    # 非标准路径 / 32 位系统回退
    $csc = "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319\csc.exe"
}
if (-not (Test-Path $csc)) { throw "找不到 csc.exe，请确认已安装 .NET Framework 4.x" }
if (-not (Test-Path $src)) { throw "找不到源码 $src" }

if (Test-Path $dist) { Remove-Item $dist -Recurse -Force }
New-Item -ItemType Directory -Force -Path $dist | Out-Null

Write-Host "编译器: $csc"
Write-Host "源码  : $src"
Write-Host ''

# 控制台子系统：命令行是本工具的主要接口，所以保留控制台。
# 放进计划任务时加 --quiet 可以自隐藏窗口（见 README）。
& $csc /nologo /target:exe /platform:x64 /optimize+ /out:"$out" $src
if ($LASTEXITCODE -ne 0) { throw '编译失败' }

$f = Get-Item $out
$h = (Get-FileHash $out -Algorithm SHA256).Hash.ToLower()
Write-Host ''
Write-Host ("产物: {0}  ({1} 字节)" -f $f.Name, $f.Length)
Write-Host ("SHA256: {0}" -f $h)
Write-Host ''
Write-Host '冒烟测试:'
& $out list
if ($LASTEXITCODE -ne 0) { throw '冒烟测试失败' }
Write-Host ''
Write-Host '完成。'
