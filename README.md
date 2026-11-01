# ProtonBridgeDualboot

Run one Proton Mail Bridge on an always-on Linux host and share it between the
Windows and Linux installs of a dual-boot machine. Each OS keeps its **own
local Thunderbird profile** (sharing a single profile across OSes breaks on
version skew and on per-install Bridge passwords) and reaches Bridge through an
SSH tunnel, so Thunderbird keeps using `127.0.0.1:1143` (IMAP) and
`127.0.0.1:1025` (SMTP).

```
Thunderbird -> 127.0.0.1:1143/1025 -> ssh -L -> <bridge-host> 127.0.0.1:1143/1025 -> Bridge
```

## Prerequisites
- Bridge running on `<bridge-host>`, logged in and unlocked. Its CLI `info`
  command prints the IMAP/SMTP password.
- Passwordless (key-based) SSH from each OS to `<bridge-host>`.
- No local Bridge running on the dual-boot machine, so ports 1143/1025 are free.

## Windows
```powershell
.\windows\install.ps1 -BridgeHost <bridge-host>   # per-user logon task, no admin
.\windows\uninstall.ps1
```
`tunnel.vbs` runs `ssh -N -L ...` with no window and relaunches it on exit with
exponential backoff (5s up to 5min, reset after a connection lasting 60s or
more). It is installed to `%LOCALAPPDATA%\ProtonBridgeTunnel`.

## Linux
```sh
./linux/install.sh <bridge-host>   # systemd user service
```
Uses `Restart=always` with `RestartSteps`/`RestartMaxDelaySec` for the same
backoff (systemd 254 or newer).

## Thunderbird
Restart Thunderbird once the tunnel is up, enter the Bridge password once per
profile, and accept Bridge's certificate when asked. With a single Bridge there
is only one password and certificate for both operating systems.
