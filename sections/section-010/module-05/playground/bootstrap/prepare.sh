#!/usr/bin/env bash
# OS prep for the "/etc/fstab in Depth" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
# Puts a labelled ext4 filesystem on each spare disk so there is something
# real to add to /etc/fstab, and keeps a pristine copy of the file.
set -euo pipefail

A=/dev/disk/by-id/virtio-s015m01-a
B=/dev/disk/by-id/virtio-s015m01-b

for _ in $(seq 1 30); do [ -e "$A" ] && [ -e "$B" ] && break; sleep 1; done
sudo udevadm settle --timeout=30 || true

n=1
for d in "$A" "$B"; do
  if [ -e "$d" ]; then
    blkid "$d" >/dev/null 2>&1 || sudo mkfs.ext4 -q -L "DATA$n" "$d"
  else
    echo "[playground] WARNING: $d did not appear."
  fi
  n=$((n+1))
done

[ -e /etc/fstab.orig ] || sudo cp /etc/fstab /etc/fstab.orig

echo "[playground] ready. Two spare ext4 filesystems (labels DATA1, DATA2) on the spare disks."
echo "[playground] /etc/fstab backed up to /etc/fstab.orig. Get UUIDs with: sudo blkid"
