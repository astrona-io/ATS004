#!/usr/bin/env bash
# OS prep for the "Partitioning Raw Storage" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
# Guarantees the scratch disk starts with no partition table so the fdisk /
# parted walkthrough begins from a clean slate.
set -euo pipefail

DEV=/dev/disk/by-id/virtio-s10m02-raw

echo "[playground] section-010-module-02: waiting for the scratch disk..."
for _ in $(seq 1 30); do
  [ -e "$DEV" ] && break
  sleep 1
done
sudo udevadm settle --timeout=30 || true

if [ -e "$DEV" ]; then
  REAL=$(readlink -f "$DEV")
  END=$(( $(sudo blockdev --getsz "$REAL") / 2048 ))   # size in MiB
  sudo wipefs -a "$DEV" || true
  # Clear the GPT primary header (start) and backup header (last MiB).
  sudo dd if=/dev/zero of="$DEV" bs=1M count=16 conv=fsync || true
  sudo dd if=/dev/zero of="$DEV" bs=1M seek=$(( END - 16 )) count=16 conv=fsync || true
  sudo partprobe "$DEV" || true
  echo "[playground] scratch disk $DEV has no partition table."
else
  echo "[playground] WARNING: $DEV never appeared; check the runtime's extraDisks."
fi

echo "[playground] ready. The scratch disk is commonly /dev/vdb — confirm with 'lsblk'."
