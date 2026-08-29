#!/usr/bin/env bash
# OS prep for the "systemd Mount and Automount Units" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
set -euo pipefail

DEV=/dev/disk/by-id/virtio-s015m02-a
for _ in $(seq 1 30); do [ -e "$DEV" ] && break; sleep 1; done
sudo udevadm settle --timeout=30 || true

if [ -e "$DEV" ]; then
  blkid "$DEV" >/dev/null 2>&1 || sudo mkfs.ext4 -q -L DATA "$DEV"
else
  echo "[playground] WARNING: $DEV did not appear."
fi

[ -e /etc/fstab.orig ] || sudo cp /etc/fstab /etc/fstab.orig

echo "[playground] ready. Spare ext4 filesystem (label DATA) on the spare disk (commonly /dev/vdb)."
echo "[playground] /etc/fstab backed up to /etc/fstab.orig. UUID: sudo blkid /dev/vdb"
