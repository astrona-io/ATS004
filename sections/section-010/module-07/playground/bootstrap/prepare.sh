#!/usr/bin/env bash
# OS prep for the "Removable Media and FAT32" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
set -euo pipefail

DEV=/dev/disk/by-id/virtio-s010m07-media
for _ in $(seq 1 30); do [ -e "$DEV" ] && break; sleep 1; done
sudo udevadm settle --timeout=30 || true

if [ ! -e "$DEV" ]; then
  echo "[playground] WARNING: $DEV did not appear."
fi

echo "[playground] ready. Blank spare disk (commonly /dev/vdb). Confirm with: lsblk"
