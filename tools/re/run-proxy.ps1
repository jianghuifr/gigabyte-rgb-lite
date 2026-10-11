$ErrorActionPreference = 'Continue'
$root  = 'C:\Program Files\GIGABYTE\Control Center'
$work = $PSScriptRoot
$log   = Join-Path $work 'driver.log'
$plog  = Join-Path $work 'ghid-proxy.log'
Set-Content -Path $log -Value ("=== proxy driver {0} ===" -f (Get-Date)) -Encoding UTF8
function Say($s) { Add-Content -Path $log -Value $s -Encoding UTF8 }

Say ("admin = " + (New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))

$realDll   = Join-Path $root 'GHidApi.dll'
$backupDll = Join-Path $root 'GHidApi.orig.dll'
$proxyDll  = Join-Path $work 'GHidApi.dll'

if (-not (Test-Path $realDll)) { Say "ERROR: $realDll not found"; exit 1 }

# --- deploy ---
Remove-Item $plog -ErrorAction SilentlyContinue
if (Test-Path $backupDll) { Remove-Item $backupDll -Force -ErrorAction SilentlyContinue }
Copy-Item $realDll $backupDll -Force
Copy-Item $proxyDll $realDll -Force
Say ("deployed proxy; backup at " + $backupDll + " size=" + (Get-Item $backupDll).Length)

$marker = Join-Path $root 'usdata2.xml'
$before = (Get-Item $marker).LastWriteTimeUtc
Say ("usdata2.xml before = " + $before.ToString('s'))

try {
    # --- run GCC ---
    $exe = Join-Path $root 'GCC.exe'
    Start-Process -FilePath $exe -ArgumentList '-b' -WorkingDirectory $root | Out-Null
    Say 'GCC launched'

    $deadline = (Get-Date).AddSeconds(150)
    $applied = $false
    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Milliseconds 500
        $now = (Get-Item $marker).LastWriteTimeUtc
        if ($now -ne $before) { $applied = $true; Say ("profile applied at " + $now.ToString('s')); break }
        if (-not (Get-Process GCC -ErrorAction SilentlyContinue)) { Say 'GCC exited by itself'; break }
    }
    if (-not $applied) { Say 'WARN: no profile rewrite seen' }

    # let the LED threads run a bit so we capture the full sequence
    Start-Sleep -Seconds 20
}
finally {
    # --- restore ---
    foreach ($n in 'GCC','GCCMbSensord','GCCGpuSensord','GvLoader') {
        Get-Process -Name $n -ErrorAction SilentlyContinue | ForEach-Object { try { $_.Kill() } catch {} }
    }
    Start-Sleep -Seconds 2
    Copy-Item $backupDll $realDll -Force
    Remove-Item $backupDll -Force -ErrorAction SilentlyContinue
    Say 'restored original GHidApi.dll'
    Say ("original size now = " + (Get-Item $realDll).Length)

    # GCC re-enables its own task when it starts
    & schtasks.exe /Change /TN "GCC" /DISABLE 2>&1 | ForEach-Object { Say ("  schtasks: " + $_) }
}

Say ("GCC processes left: " + ((Get-Process GCC -ErrorAction SilentlyContinue | Measure-Object).Count))
if (Test-Path $plog) { Say ("proxy log size = " + (Get-Item $plog).Length) } else { Say 'NO proxy log produced' }
Say '=== done ==='

