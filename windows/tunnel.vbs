' Keeps the SSH tunnel to the Proton Mail Bridge on the bridge host alive, with no window.
' Exponential backoff 5s -> 5min; resets after a connection that lasted >= 60s.
' Host is required as the first argument.
Set sh = CreateObject("WScript.Shell")
If WScript.Arguments.Count < 1 Then WScript.Quit 1
host = WScript.Arguments(0)
delay = 5
Do
  t0 = Timer
  sh.Run "ssh.exe -N -o BatchMode=yes -o ConnectTimeout=10 -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -L 127.0.0.1:1143:127.0.0.1:1143 -L 127.0.0.1:1025:127.0.0.1:1025 " & host, 0, True
  ran = Timer - t0
  If ran < 0 Then ran = 0
  If ran >= 60 Then delay = 5
  WScript.Sleep delay * 1000
  delay = delay * 2
  If delay > 300 Then delay = 300
Loop
