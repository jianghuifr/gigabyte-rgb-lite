$ErrorActionPreference = 'Continue'
$root   = 'C:\Program Files\GIGABYTE\Control Center'
$eneDir = 'C:\Program Files\ENE\Aac_ENE_DRAM_RGB_AIO\x64'
$work = $PSScriptRoot
$memXml = Join-Path $root 'RGBMemory\Profile-0.xml'
$bakXml = Join-Path $work 'RGBMemory-Profile-0.xml.bak'
$log    = Join-Path $work 'driver-msio.log'
$plog   = Join-Path $work 'msio-proxy.log'
Set-Content -Path $log -Value ("=== MsIo64_ENE capture {0} ===" -f (Get-Date)) -Encoding UTF8
function Say($s) { Add-Content -Path $log -Value $s -Encoding UTF8 }

Say ("admin = " + (New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))

$realDll   = Join-Path $eneDir 'MsIo64_ENE.dll'
$backupDll = Join-Path $eneDir 'MsIo64_ENE.orig.dll'
$proxyDll  = Join-Path $work 'MsIo64_ENE.dll'
if (-not (Test-Path $realDll)) { Say "ERROR: $realDll missing"; exit 1 }

# 1) patch GCC memory profile to Still + red so a COLOUR command gets sent
Copy-Item $memXml $bakXml -Force
$xml = Get-Content $memXml -Raw
$xml2 = $xml -replace '<EffectMode>Off</EffectMode>', '<EffectMode>Still</EffectMode>'
$xml2 = $xml2 -replace '<LedColor0>4278190080</LedColor0>', '<LedColor0>4294901760</LedColor0>'
[System.IO.File]::WriteAllText($memXml, $xml2, [System.Text.Encoding]::UTF8)
Say ("memory profile patched -> Still + red (Still count = " + ([regex]::Matches($xml2, '<EffectMode>Still</EffectMode>').Count) + ")")

# 2) deploy proxy
Remove-Item $plog -ErrorAction SilentlyContinue
Remove-Item $backupDll -Force -ErrorAction SilentlyContinue
Copy-Item $realDll $backupDll -Force
Copy-Item $proxyDll $realDll -Force
Say 'MsIo64_ENE proxy deployed'

$marker = Join-Path $root 'usdata2.xml'
$mbefore = (Get-Item $marker).LastWriteTimeUtc

try {
    Start-Process -FilePath (Join-Path $root 'GCC.exe') -ArgumentList '-b' -WorkingDirectory $root | Out-Null
    Say 'GCC launched'
    $deadline = (Get-Date).AddSeconds(180)
    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Milliseconds 500
        if ((Get-Item $marker).LastWriteTimeUtc -ne $mbefore) { Say 'profile applied'; break }
        if (-not (Get-Process GCC -ErrorAction SilentlyContinue)) { Say 'GCC exited'; break }
    }
    Start-Sleep -Seconds 35
}
finally {
    foreach ($n in 'GCC','GCCMbSensord','GCCGpuSensord','GvLoader') {
        Get-Process -Name $n -ErrorAction SilentlyContinue | ForEach-Object { try { $_.Kill() } catch {} }
    }
    Start-Sleep -Seconds 2
    Copy-Item $backupDll $realDll -Force
    Remove-Item $backupDll -Force -ErrorAction SilentlyContinue
    Copy-Item $bakXml $memXml -Force
    Say ("restored: MsIo64_ENE.dll size=" + (Get-Item $realDll).Length + "  Profile-0.xml size=" + (Get-Item $memXml).Length)
    & schtasks.exe /Change /TN "GCC" /DISABLE 2>&1 | Out-Null
}

Say ("GCC left: " + ((Get-Process GCC -ErrorAction SilentlyContinue | Measure-Object).Count))
if (Test-Path $plog) { Say ("proxy log size = " + (Get-Item $plog).Length) } else { Say 'NO proxy log produced' }
Say '=== done ==='

