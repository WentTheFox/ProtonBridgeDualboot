$name = 'ProtonBridgeTunnel'
if (Get-ScheduledTask $name -ErrorAction SilentlyContinue) {
  Stop-ScheduledTask $name
  Unregister-ScheduledTask $name -Confirm:$false
}
Get-Process wscript,ssh -ErrorAction SilentlyContinue | Stop-Process -Force
Remove-Item (Join-Path $env:LOCALAPPDATA $name) -Recurse -Force -ErrorAction SilentlyContinue
'Removed.'
