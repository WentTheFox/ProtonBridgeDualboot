#!/bin/sh
# Installs the Bridge tunnel as a systemd user service. Usage: ./install.sh <bridge-host>
set -eu
host="${1:?usage: $0 <bridge-host>}"
here="$(cd "$(dirname "$0")" && pwd)"
ssh -o BatchMode=yes -o ConnectTimeout=10 "$host" true || { echo "Passwordless SSH to $host failed" >&2; exit 1; }
mkdir -p "$HOME/.config/systemd/user"
sed "s|@BRIDGE_HOST@|$host|" "$here/protonmail-bridge-tunnel.service" > "$HOME/.config/systemd/user/protonmail-bridge-tunnel.service"
systemctl --user daemon-reload
systemctl --user enable --now protonmail-bridge-tunnel.service
systemctl --user --no-pager status protonmail-bridge-tunnel.service | head -5
