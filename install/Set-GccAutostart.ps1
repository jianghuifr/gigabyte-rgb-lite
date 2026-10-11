<#
    Set-GccAutostart.ps1
    开关技嘉 Control Center 自己的开机自启计划任务（任务名 "GCC"，执行 GCC.exe -b）。

    用法：
        powershell -ExecutionPolicy Bypass -File .\Set-GccAutostart.ps1 -Action Status
        powershell -ExecutionPolicy Bypass -File .\Set-GccAutostart.ps1 -Action Disable
        powershell -ExecutionPolicy Bypass -File .\Set-GccAutostart.ps1 -Action Enable

    注意：该任务由 GCC 以最高权限创建，Enable/Disable 可能需要以管理员身份运行 PowerShell。
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Status', 'Disable', 'Enable')]
    [string]$Action
)

$ErrorActionPreference = 'Continue'

if ($Action -eq 'Status') {
    $t = Get-ScheduledTask -TaskName 'GCC' -ErrorAction SilentlyContinue
    if ($null -eq $t) { Write-Host '未找到名为 GCC 的计划任务。'; return }
    $i = Get-ScheduledTaskInfo -TaskName 'GCC' -ErrorAction SilentlyContinue
    Write-Host ("任务名 : {0}" -f $t.TaskName)
    Write-Host ("状态   : {0}" -f $t.State)
    if ($i) { Write-Host ("上次运行: {0}" -f $i.LastRunTime) }
    return
}

try {
    if ($Action -eq 'Disable') {
        Disable-ScheduledTask -TaskName 'GCC' | Out-Null
        Write-Host 'GCC 开机自启已【禁用】。重新启用： -Action Enable'
    }
    else {
        Enable-ScheduledTask -TaskName 'GCC' | Out-Null
        Write-Host 'GCC 开机自启已【启用】。'
    }
}
catch {
    Write-Host "操作失败：$($_.Exception.Message)"
    Write-Host '请用「以管理员身份运行」的 PowerShell 重试，例如：'
    Write-Host ("  Start-Process powershell -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -File ""{0}"" -Action {1}'" -f $MyInvocation.MyCommand.Path, $Action)
}
