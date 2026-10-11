# Restore-ENE-Driver.ps1
#
# Safety net for uninstalling GIGABYTE Control Center.
#
# Dependency chain for the DDR5 DIMM lighting channel (verified by inspection
# and by a live teardown drill):
#
#   GccLiteAll.exe
#     -> %LOCALAPPDATA%\GccLite\ene\MsIo64_ENE.dll     (CTI "CtiIo for ENE", imports only Win32)
#          -> CreateFileW("\\.\CTIIO")                  <-- THE one that matters
#               -> CTIIO service -> C:\Windows\system32\drivers\CtiIo64.sys
#
# Note: the MSIO / MsIo64.sys driver is a DIFFERENT component and is NOT used by
# the DIMM RGB path - the teardown drill proved the lights keep working with it
# removed. It is checked here only because GCC installs it too.
#
# Run elevated AFTER uninstalling GCC if the DIMM lights stop responding:
#   powershell -ExecutionPolicy Bypass -File tools\restore-vendor-drivers.ps1

$ErrorActionPreference = 'Continue'
$ld = Join-Path $env:LOCALAPPDATA 'GccLite'

function Say($s) { Write-Host $s }

$admin = (New-Object System.Security.Principal.WindowsPrincipal(
    [System.Security.Principal.WindowsIdentity]::GetCurrent())
).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) { Write-Host 'ERROR: run this elevated (Run as administrator).' -ForegroundColor Red; exit 1 }

function Fix-Service {
    param([string]$Name, [string]$SysFile, [string]$StartType = 'system')

    Say ("=== service " + $Name + "  (" + $SysFile + ") ===")
    $dest = Join-Path 'C:\WINDOWS\system32\drivers' $SysFile
    $bak  = Join-Path $ld ($SysFile + '.bak')

    # 1) driver file
    if (Test-Path $dest) {
        Say ("  OK   file  " + $dest + "  (" + (Get-Item $dest).Length + " bytes)")
    } elseif (Test-Path $bak) {
        Copy-Item $bak $dest -Force
        Say ("  FIXED file restored from " + $bak)
    } else {
        Say ("  MISSING file and no backup: " + $dest) -ForegroundColor Yellow
    }

    # 2) service registration
    $svc = Get-ItemProperty ("HKLM:\SYSTEM\CurrentControlSet\Services\" + $Name) -ErrorAction SilentlyContinue
    if ($svc) {
        Say ("  OK   service present  Start=" + $svc.Start + "  ImagePath=" + $svc.ImagePath)
    } else {
        Say '  MISSING service - recreating ...'
        & sc.exe create $Name type= kernel start= $StartType binPath= ("System32\drivers\" + $SysFile) 2>&1 |
            ForEach-Object { Say ("       " + $_) }
        & sc.exe start $Name 2>&1 | ForEach-Object { Say ("       " + $_) }
    }

    # 3) runtime state
    $st = (& sc.exe query $Name 2>&1 | Select-String -Pattern 'STATE') -join ' '
    Say ("  state:" + $st.Trim())
    Say ''
}

Fix-Service -Name 'CTIIO'  -SysFile 'CtiIo64.sys'
Fix-Service -Name 'CTIAIO' -SysFile 'CtiAIo64.sys'
Fix-Service -Name 'MSIO'   -SysFile 'MsIo64.sys'

Say '=== ENE SMBus DLL (our self-contained copy) ==='
$ene = Join-Path $ld 'ene'
if (Test-Path (Join-Path $ene 'MsIo64_ENE.dll')) {
    Say ("  OK   " + (Join-Path $ene 'MsIo64_ENE.dll') + "  (" + (Get-Item (Join-Path $ene 'MsIo64_ENE.dll')).Length + " bytes)")
} else {
    $bak = Join-Path $ld 'ENE-backup\Aac_ENE_DRAM_RGB_AIO\x64'
    if (Test-Path (Join-Path $bak 'MsIo64_ENE.dll')) {
        New-Item -ItemType Directory -Force -Path $ene | Out-Null
        Copy-Item (Join-Path $bak '*') $ene -Force -Recurse
        Say ("  FIXED restored from " + $bak)
    } else {
        Say '  MISSING - re-run ENE''s own installer:' -ForegroundColor Yellow
        Say '          C:\Program Files\ENE\Aac_ENE_DRAM_RGB_AIO\x86\InstDrvMS_un.exe'
    }
}

Say ''
Say '=== live check (DDR5 only, green) ==='
$exe = Join-Path $ld 'GccLiteHidden.exe'
if (Test-Path $exe) {
    Start-Process -FilePath $exe -ArgumentList 'color 00FF00 --smb-only' -Wait
    Start-Sleep -Seconds 2
    $log = Join-Path $ld 'GccLiteAll.log'
    if (Test-Path $log) { Get-Content $log -Tail 6 | ForEach-Object { Say ("  " + $_) } }
    Say ''
    Say 'If the DDR5 LEDs just turned green, everything is restored.'
} else {
    Say ("  (tool not found at " + $exe + ")")
}

