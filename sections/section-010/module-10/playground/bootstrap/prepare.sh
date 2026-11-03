#!/usr/bin/env bash
# OS prep for the "Btrfs Basics" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
set -euo pipefail

for serial in s010m10-a s010m10-b; do
  DEV="/dev/disk/by-id/virtio-${serial}"
  for _ in $(seq 1 30); do [ -e "$DEV" ] && break; sleep 1; done
  [ -e "$DEV" ] || echo "[playground] WARNING: $DEV did not appear."
done
sudo udevadm settle --timeout=30 || true

if ! command -v mkfs.btrfs >/dev/null 2>&1; then
  sudo apt-get update -qq || true
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq btrfs-progs
fi

[ -e /etc/fstab.orig ] || sudo cp /etc/fstab /etc/fstab.orig

echo "[playground] ready. Two blank spare disks (commonly /dev/vdb 2 GB and /dev/vdc 1 GB)."
echo "[playground] /etc/fstab backed up to /etc/fstab.orig."
