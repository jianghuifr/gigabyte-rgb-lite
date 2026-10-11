$ErrorActionPreference = 'Continue'
$root = 'C:\Program Files\GIGABYTE\Control Center'
$work = $PSScriptRoot
$log  = Join-Path $work 'driver-ycc.log'
$plog = Join-Path $work 'ycc-proxy.log'
Set-Content -Path $log -Value ("=== YccDrvv3 proxy driver {0} ===" -f (Get-Date)) -Encoding UTF8
function Say($s) { Add-Content -Path $log -Value $s -Encoding UTF8 }

Say ("admin = " + (New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))

$realDll   = Join-Path $root 'YccDrvv3.dll'
$backupDll = Join-Path $root 'YccDrvv3.orig.dll'
$proxyDll  = Join-Path $work 'YccDrvv3.dll'

if (-not (Test-Path $realDll)) { Say "ERROR: $realDll not found"; exit 1 }

Remove-Item $plog -ErrorAction SilentlyContinue
Remove-Item $backupDll -Force -ErrorAction SilentlyContinue
Copy-Item $realDll $backupDll -Force
Copy-Item $proxyDll $realDll -Force
Say ("deployed YccDrvv3 proxy; backup size=" + (Get-Item $backupDll).Length)

$marker = Join-Path $root 'usdata2.xml'
$before = (Get-Item $marker).LastWriteTimeUtc

try {
    Start-Process -FilePath (Join-Path $root 'GCC.exe') -ArgumentList '-b' -WorkingDirectory $root | Out-Null
    Say 'GCC launched'
    $deadline = (Get-Date).AddSeconds(150)
    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Milliseconds 500
        if ((Get-Item $marker).LastWriteTimeUtc -ne $before) { Say 'profile applied'; break }
        if (-not (Get-Process GCC -ErrorAction SilentlyContinue)) { Say 'GCC exited'; break }
    }
    Start-Sleep -Seconds 20
}
finally {
    foreach ($n in 'GCC','GCCMbSensord','GCCGpuSensord','GvLoader') {
        Get-Process -Name $n -ErrorAction SilentlyContinue | ForEach-Object { try { $_.Kill() } catch {} }
    }
    Start-Sleep -Seconds 2
    Copy-Item $backupDll $realDll -Force
    Remove-Item $backupDll -Force -ErrorAction SilentlyContinue
    Say ("restored YccDrvv3.dll, size now = " + (Get-Item $realDll).Length)
    & schtasks.exe /Change /TN "GCC" /DISABLE 2>&1 | ForEach-Object { Say ("  schtasks: " + $_) }
}

Say ("GCC processes left: " + ((Get-Process GCC -ErrorAction SilentlyContinue | Measure-Object).Count))
if (Test-Path $plog) {
    $sz = (Get-Item $plog).Length
    Say ("proxy log size = $sz")
} else { Say 'NO proxy log produced' }
Say '=== done ==='

