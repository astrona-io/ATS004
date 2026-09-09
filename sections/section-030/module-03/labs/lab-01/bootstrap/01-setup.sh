#!/usr/bin/env bash
set -eu

DISKS=(
  /dev/disk/by-id/virtio-lab033-a
  /dev/disk/by-id/virtio-lab033-b
  /dev/disk/by-id/virtio-lab033-c
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
  fi
done
