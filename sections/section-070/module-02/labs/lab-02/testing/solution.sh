#!/usr/bin/env bash
set -euo pipefail
pid=$(sudo lsof -t +L1 /mnt/spool | head -1)
test -n "$pid"
printf '%s
' "$pid" | sudo tee /root/holder-pid.txt
sudo kill "$pid"
for i in $(seq 1 20); do test ! -d /proc/$pid && break; sleep 1; done
sudo tee /etc/udev/rules.d/70-spool.rules >/dev/null <<'REFERENCE_FILE'
ACTION=="add|change", SUBSYSTEM=="block", ATTRS{serial}=="lab070202-spool", ATTR{queue/scheduler}="mq-deadline"
REFERENCE_FILE
sudo udevadm control --reload
disk=$(basename "$(readlink -f /dev/disk/by-id/virtio-lab070202-spool)")
sudo udevadm trigger --action=change --name-match="$disk"
sudo udevadm settle
