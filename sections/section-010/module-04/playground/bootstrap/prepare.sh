#!/usr/bin/env bash
# OS prep for the "Filesystem Maintenance, Labeling, and Tuning" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
# Puts an UNMOUNTED ext4 filesystem with a label and a couple of files on the
# scratch disk, so fsck / tune2fs / blkid have something real to inspect.
set -euo pipefail

DEV=/dev/disk/by-id/virtio-s10m04-fs

echo "[playground] section-010-module-04: waiting for the scratch disk..."
for _ in $(seq 1 30); do
  [ -e "$DEV" ] && break
  sleep 1
done
sudo udevadm settle --timeout=30 || true

if [ -e "$DEV" ]; then
  sudo wipefs -a "$DEV" || true
  sudo mkfs.ext4 -F -L "OLD_LABEL" "$DEV"
  TMP=$(mktemp -d)
  sudo mount "$DEV" "$TMP"
  echo "sample content" | sudo tee "$TMP/report.txt" >/dev/null
  sudo mkdir -p "$TMP/archive"
  echo "more content" | sudo tee "$TMP/archive/notes.txt" >/dev/null
  sudo umount "$TMP"
  rmdir "$TMP"
  echo "[playground] $DEV holds an unmounted ext4 filesystem labelled OLD_LABEL."
else
  echo "[playground] WARNING: $DEV never appeared; check the runtime's extraDisks."
fi

echo "[playground] ready. The scratch disk is commonly /dev/vdb — confirm with 'lsblk -f'."
