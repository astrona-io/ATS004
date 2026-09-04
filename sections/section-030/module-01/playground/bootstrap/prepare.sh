#!/usr/bin/env bash
# OS prep for the "LVM Fundamentals" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
# Makes sure lvm2 is installed and the three spare disks carry no LVM
# metadata or filesystem signatures, so pvcreate/vgcreate start from nothing.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

DISKS=(
  /dev/disk/by-id/virtio-s30m01-a
  /dev/disk/by-id/virtio-s30m01-b
  /dev/disk/by-id/virtio-s30m01-c
)

for _ in $(seq 1 30); do
  missing=0
  for d in "${DISKS[@]}"; do [ -e "$d" ] || missing=1; done
  [ "$missing" -eq 0 ] && break
  sleep 1
done
sudo udevadm settle --timeout=30 || true

for d in "${DISKS[@]}"; do
  if [ -e "$d" ]; then
    sudo wipefs -a "$d" || true
    sudo dd if=/dev/zero of="$d" bs=1M count=8 conv=fsync || true
  else
    echo "[playground] WARNING: $d did not appear."
  fi
done

echo "[playground] ready. Spare disks are commonly /dev/vdb /dev/vdc /dev/vdd — confirm with 'lsblk'."
