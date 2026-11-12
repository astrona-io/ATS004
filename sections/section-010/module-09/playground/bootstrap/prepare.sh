#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# OS prep for the "XFS: Creating, Growing and Repairing" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
set -euo pipefail

for DEV in /dev/disk/by-id/virtio-s010m09-a /dev/disk/by-id/virtio-s010m09-b; do
  for _ in $(seq 1 30); do [ -e "$DEV" ] && break; sleep 1; done
  [ -e "$DEV" ] || echo "[playground] WARNING: $DEV did not appear."
done
sudo udevadm settle --timeout=30 || true

[ -e /etc/fstab.orig ] || sudo cp /etc/fstab /etc/fstab.orig

echo "[playground] ready. Two blank spare disks (1 GB and 2 GB), commonly /dev/vdb and /dev/vdc."
echo "[playground] /etc/fstab backed up to /etc/fstab.orig. Confirm the disk names with: lsblk"
ASTRONA_STUDENT_SCRIPT
