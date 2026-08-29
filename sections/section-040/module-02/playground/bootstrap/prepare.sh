#!/usr/bin/env bash
# OS prep for the "Swap Partitions & Priority Scheduling" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
# Wipes the spare disk back to raw, keeps a pristine copy of /etc/fstab so
# edits are easy to undo, and clears any leftover swap from a previous run.
set -euo pipefail

DEV=/dev/disk/by-id/virtio-s40m02-swap

for _ in $(seq 1 30); do
  [ -e "$DEV" ] && break
  sleep 1
done
sudo udevadm settle --timeout=30 || true

# Undo leftovers from a re-used environment.
sudo swapoff /swapfile 2>/dev/null || true
[ -e /swapfile ] && sudo rm -f /swapfile
if [ -e "$DEV" ]; then
  for p in "${DEV}"-part* "$(readlink -f "$DEV")"*; do
    [ -e "$p" ] && sudo swapoff "$p" 2>/dev/null || true
  done
  sudo wipefs -a "$DEV" || true
  sudo dd if=/dev/zero of="$DEV" bs=1M count=16 conv=fsync || true
  sudo partprobe "$DEV" || true
else
  echo "[playground] WARNING: $DEV did not appear."
fi

# Pristine fstab copy for easy rollback after editing.
[ -e /etc/fstab.orig ] || sudo cp /etc/fstab /etc/fstab.orig

echo "[playground] memory and swap at start:"
free -h
swapon --show || echo "(no swap active)"
echo "[playground] spare disk is commonly /dev/vdb (raw). /etc/fstab backed up to /etc/fstab.orig."
