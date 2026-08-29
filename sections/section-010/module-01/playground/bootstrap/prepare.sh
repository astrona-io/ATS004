#!/usr/bin/env bash
# OS prep for the "Lifecycle of Local Storage" playground.
# Runs once when the environment comes up. Environment preparation only:
# there is no task and no grading. This just guarantees the scratch disk
# starts life genuinely raw, so `lsblk` / `blkid` behave the way the
# chapter describes.
set -euo pipefail

DEV=/dev/disk/by-id/virtio-s10m01-raw

echo "[playground] section-010-module-01: waiting for the scratch disk to appear..."
for _ in $(seq 1 30); do
  [ -e "$DEV" ] && break
  sleep 1
done
sudo udevadm settle --timeout=30 || true

if [ -e "$DEV" ]; then
  # Zap any partition table / filesystem signature left over from a previous
  # run so the disk shows up unformatted and unmounted.
  sudo wipefs -a "$DEV" || true
  sudo dd if=/dev/zero of="$DEV" bs=1M count=16 conv=fsync || true
  echo "[playground] scratch disk $DEV wiped back to raw."
else
  echo "[playground] WARNING: $DEV never appeared; check the runtime's extraDisks."
fi

echo "[playground] ready. The raw disk is commonly /dev/vdb — confirm with 'lsblk'."
