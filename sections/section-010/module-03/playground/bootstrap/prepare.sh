#!/usr/bin/env bash
# OS prep for the "Securing Data-at-Rest with LUKS" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
# Makes sure the scratch disk is raw so `cryptsetup luksFormat` starts clean.
set -euo pipefail

DEV=/dev/disk/by-id/virtio-s10m03-raw

echo "[playground] section-010-module-03: waiting for the scratch disk..."
for _ in $(seq 1 30); do
  [ -e "$DEV" ] && break
  sleep 1
done
sudo udevadm settle --timeout=30 || true

if [ -e "$DEV" ]; then
  # Close any leftover mapping from a previous run, then wipe signatures.
  for m in /dev/mapper/secure_vault /dev/mapper/vault; do
    [ -e "$m" ] && sudo cryptsetup close "$(basename "$m")" || true
  done
  sudo wipefs -a "$DEV" || true
  sudo dd if=/dev/zero of="$DEV" bs=1M count=16 conv=fsync || true
  echo "[playground] scratch disk $DEV wiped back to raw."
else
  echo "[playground] WARNING: $DEV never appeared; check the runtime's extraDisks."
fi

echo "[playground] ready. The scratch disk is commonly /dev/vdb — confirm with 'lsblk'."
