<#
.SYNOPSIS  Installs the Bridge tunnel as a per-user logon task (no admin needed).
.PARAMETER BridgeHost  SSH host running Proton Mail Bridge (key auth must already work).
#>
param([Parameter(Mandatory)][string]$BridgeHost)
$ErrorActionPreference = 'Stop'
$name = 'ProtonBridgeTunnel'
$dir  = Join-Path $env:LOCALAPPDATA $name
New-Item -ItemType Directory -Force $dir | Out-Null
Copy-Item (Join-Path $PSScriptRoot 'tunnel.vbs') "$dir\tunnel.vbs" -Force

& ssh.exe -o BatchMode=yes -o ConnectTimeout=10 $BridgeHost true
if ($LASTEXITCODE -ne 0) { throw "Passwordless SSH to $BridgeHost failed; fix that first." }

if (Get-ScheduledTask $name -ErrorAction SilentlyContinue) {
  Stop-ScheduledTask $name; Get-Process wscript,ssh -ErrorAction SilentlyContinue | Stop-Process -Force
}
$action   = New-ScheduledTaskAction -Execute 'wscript.exe' -Argument "`"$dir\tunnel.vbs`" $BridgeHost"
$trigger  = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit ([TimeSpan]::Zero) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask $name -Action $action -Trigger $trigger -Settings $settings -Force `
  -Description "SSH tunnel to Proton Mail Bridge on $BridgeHost (IMAP 1143, SMTP 1025)" | Out-Null
Start-ScheduledTask $name
Start-Sleep 5
$up = Get-NetTCPConnection -State Listen -LocalPort 1143,1025 -ErrorAction SilentlyContinue
if ($up.Count -ge 2) { 'Tunnel is up on 127.0.0.1:1143 and :1025.' } else { Write-Warning 'Ports not listening yet; check the bridge host.' }
