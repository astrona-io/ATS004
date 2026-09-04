#!/usr/bin/env bash
# OS prep for the "Software RAID Fundamentals" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
# Makes sure mdadm is installed and the four spare disks carry no RAID
# metadata or filesystem signatures, so `mdadm --create` starts from nothing.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

DISKS=(
  /dev/disk/by-id/virtio-s090m01-a
  /dev/disk/by-id/virtio-s090m01-b
  /dev/disk/by-id/virtio-s090m01-c
  /dev/disk/by-id/virtio-s090m01-d
)

for _ in $(seq 1 30); do
  ok=1; for d in "${DISKS[@]}"; do [ -e "$d" ] || ok=0; done
  [ "$ok" -eq 1 ] && break; sleep 1
done
sudo udevadm settle --timeout=30 || true

for d in "${DISKS[@]}"; do
  if [ -e "$d" ]; then
    sudo mdadm --zero-superblock "$d" 2>/dev/null || true
    sudo wipefs -a "$d" || true
    sudo dd if=/dev/zero of="$d" bs=1M count=8 conv=fsync || true
  else
    echo "[playground] WARNING: $d did not appear."
  fi
done

echo "[playground] ready. Four raw spare disks (commonly /dev/vdb /dev/vdc /dev/vdd /dev/vde)."
echo "[playground] mdadm is installed. Build an array with 'mdadm --create'."
