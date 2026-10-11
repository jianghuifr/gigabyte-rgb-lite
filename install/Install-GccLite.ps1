# GccLite 安装脚本（提权运行）
#
#   powershell -ExecutionPolicy Bypass -File Install-GccLite.ps1
#
# 做四件事：
#   1. 把 exe 复制到 %LOCALAPPDATA%\GccLite\
#   2. 注册开机自启任务 GccLiteAll（登录后延迟 15 秒、最高权限，直接调用 exe）
#   3. 注册按需灯效任务 GccLiteFx-*，并生成双击启动器
#   4. 禁用技嘉自己的 GCC 自启任务

$ErrorActionPreference = 'Continue'

$admin = (New-Object System.Security.Principal.WindowsPrincipal(
    [System.Security.Principal.WindowsIdentity]::GetCurrent())
).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) { Write-Host 'ERROR: 请以管理员身份运行。' -ForegroundColor Red; exit 1 }

$repo = $PSScriptRoot
if ((Split-Path $repo -Leaf) -eq 'install') { $repo = Split-Path $repo -Parent }
$ld   = Join-Path $env:LOCALAPPDATA 'GccLite'
New-Item -ItemType Directory -Force -Path $ld | Out-Null
$fx = Join-Path $ld 'Effects'
New-Item -ItemType Directory -Force -Path $fx | Out-Null

# ---------- 1. 编译（如果还没有 exe）----------
$src = Join-Path $repo 'src\GccLiteAll.cs'
$csc = "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
$con = Join-Path $ld 'GccLiteAll.exe'
$hid = Join-Path $ld 'GccLiteHidden.exe'
if (-not (Test-Path $src)) { Write-Host "ERROR: 找不到 $src" -ForegroundColor Red; exit 1 }
if (-not (Test-Path $csc)) { Write-Host "ERROR: 找不到 csc.exe" -ForegroundColor Red; exit 1 }
Write-Host '[1/4] 编译 ...'
& $csc /nologo /target:exe    /platform:x64 /optimize+ /out:$con $src | Out-Null
& $csc /nologo /target:winexe /platform:x64 /optimize+ /out:$hid $src | Out-Null
if (-not (Test-Path $hid)) { Write-Host 'ERROR: 编译失败' -ForegroundColor Red; exit 1 }
Write-Host ("      控制台版 " + (Get-Item $con).Length + " B / 无窗口版 " + (Get-Item $hid).Length + " B")

# ---------- 2. 开机自启任务 ----------
Write-Host '[2/4] 注册开机自启任务 GccLiteAll ...'
$action    = New-ScheduledTaskAction -Execute $hid -Argument '--off' -WorkingDirectory $ld
$trigger   = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"
$trigger.Delay = 'PT15S'
$settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
                -StartWhenAvailable -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Highest
Register-ScheduledTask -TaskName 'GccLiteAll' -Action $action -Trigger $trigger `
    -Settings $settings -Principal $principal -Force | Out-Null
Write-Host '      OK（登录后 15 秒，最高权限，直接调用 exe）'

# ---------- 3. 按需灯效任务 + 双击启动器 ----------
Write-Host '[3/4] 注册灯效任务并生成启动器 ...'
$defs = @(
    @{ n='Off';           a='off';                                        f='1-Off.cmd' },
    @{ n='On';            a='on';                                         f='2-On-White.cmd' },
    @{ n='StaticRed';     a='color FF0000';                               f='3-Static-Red.cmd' },
    @{ n='StaticGreen';   a='color 00FF00';                               f='4-Static-Green.cmd' },
    @{ n='Breath';        a='effect breath --color 00FF00';               f='5-Breath-Green.cmd' },
    @{ n='Flash';         a='effect flash --color 0000FF';                f='6-Flash-Blue.cmd' },
    @{ n='Cycle';         a='effect cycle';                               f='7-Cycle.cmd' },
    @{ n='Wave';          a='effect wave --color 00FFFF';                 f='8-Wave-Cyan.cmd' },
    @{ n='Random';        a='effect random';                              f='9-Random.cmd' },
    @{ n='SlowBreath';    a='effect breath --color FF0000 --speed 1';     f='A-Breath-Slow-Red.cmd' },
    @{ n='FastCycle';     a='effect cycle --speed 10';                    f='B-Cycle-Fast.cmd' },
    @{ n='Dim';           a='color FFFFFF --brightness 40';               f='C-Dim-White.cmd' },
    @{ n='FanOnly';       a='effect cycle --hid-only';                    f='D-FanOnly-Cycle.cmd' },
    @{ n='MemOnly';       a='effect breath --color 00FF00 --smb-only';    f='E-MemOnly-Breath.cmd' },
    @{ n='ColRed';        a='color FF0000';                               f='F1-Red.cmd' },
    @{ n='ColOrange';     a='color FF8000';                               f='F2-Orange.cmd' },
    @{ n='ColYellow';     a='color FFFF00';                               f='F3-Yellow.cmd' },
    @{ n='ColGreen';      a='color 00FF00';                               f='F4-Green.cmd' },
    @{ n='ColCyan';       a='color 00FFFF';                               f='F5-Cyan.cmd' },
    @{ n='ColBlue';       a='color 0000FF';                               f='F6-Blue.cmd' },
    @{ n='ColPurple';     a='color 8000FF';                               f='F7-Purple.cmd' },
    @{ n='ColMagenta';    a='color FF00FF';                               f='F8-Magenta.cmd' },
    @{ n='ColWhite';      a='color FFFFFF';                               f='F9-White.cmd' },
    @{ n='ColWarm';       a='color FFAA55';                               f='FA-Warm-White.cmd' },
    @{ n='Rainbow';       a='effect rainbow --color FFFFFF';              f='G-Rainbow.cmd' },
    @{ n='BreathRainbow'; a='effect breathrainbow --color FFFFFF';        f='H-Breath-Rainbow.cmd' },
    @{ n='Comet';         a='effect comet --color FFFFFF';                f='I-Comet.cmd' },
    @{ n='CometRainbow';  a='effect cometrainbow --color FFFFFF';         f='J-Comet-Rainbow.cmd' },
    @{ n='MovingFlash';   a='effect movingflash --color FFFFFF';          f='K-Moving-Flash.cmd' },
    @{ n='YoYo';          a='effect yoyo --color FFFFFF';                 f='L-YoYo.cmd' },
    @{ n='Starry';        a='effect starry --color FFFFFF';               f='M-Starry-Night.cmd' },
    @{ n='DFlash';        a='effect dflash --color FFFFFF';               f='N-Double-Flash.cmd' },
    @{ n='AorusRainbow';  a='effect aorusrainbow --color FFFFFF';         f='O-Aorus-Rainbow.cmd' },
    @{ n='ColdRainbow';   a='effect coldrainbow --color FFFFFF';          f='P-Cold-Rainbow.cmd' }
)
$fxSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
                -MultipleInstances Parallel -ExecutionTimeLimit (New-TimeSpan -Minutes 3)
foreach ($d in $defs) {
    $tn = 'GccLiteFx-' + $d.n
    Register-ScheduledTask -TaskName $tn `
        -Action (New-ScheduledTaskAction -Execute $hid -Argument $d.a -WorkingDirectory $ld) `
        -Principal $principal -Settings $fxSettings -Force | Out-Null
    $cmd = "@echo off`r`nschtasks /Run /TN `"$tn`" >nul 2>&1`r`n" +
           "if errorlevel 1 (echo FAILED: $tn) else (echo OK - $($d.n) applied)`r`n"
    Set-Content -Path (Join-Path $fx $d.f) -Value $cmd -Encoding ASCII
}
Write-Host ("      OK - " + $defs.Count + " 个任务 / 启动器 -> " + $fx)

# ---------- 4. 禁用 GCC 自启 ----------
Write-Host '[4/4] 禁用技嘉 GCC 自启任务 ...'
$gcc = Get-ScheduledTask -TaskName 'GCC' -ErrorAction SilentlyContinue
if ($gcc) {
    Disable-ScheduledTask -TaskName 'GCC' -ErrorAction SilentlyContinue | Out-Null
    Write-Host ("      GCC 任务状态: " + (Get-ScheduledTask -TaskName 'GCC').State)
} else {
    Write-Host '      未找到 GCC 任务（可能没装 GCC，或已清理）'
}

Write-Host ''
Write-Host '=== 安装完成 ==='
Write-Host ("  exe  : " + $hid)
Write-Host ("  日志 : " + (Join-Path $ld 'GccLiteAll.log'))
Write-Host ("  灯效 : " + $fx + '  (双击 .cmd 即可切换)')
Write-Host ''
Write-Host '立即测试：'
Write-Host ('  & "' + $con + '" color FF0000')
Write-Host ('  & "' + $con + '" off')
Write-Host ''
Write-Host '回滚：'
Write-Host '  Unregister-ScheduledTask -TaskName "GccLiteAll" -Confirm:$false'
Write-Host '  Get-ScheduledTask -TaskName "GccLiteFx-*" | Unregister-ScheduledTask -Confirm:$false'
Write-Host '  Enable-ScheduledTask  -TaskName "GCC"     # 恢复技嘉自启'
