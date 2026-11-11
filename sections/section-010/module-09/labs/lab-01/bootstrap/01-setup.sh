#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -eu

NEW_DISK=/dev/disk/by-id/virtio-lab091-new
OLD_DISK=/dev/disk/by-id/virtio-lab091-old

for disk in "$NEW_DISK" "$OLD_DISK"; do
  for _ in $(seq 1 30); do
    [ -e "$disk" ] && break
    sleep 1
  done
done

sudo udevadm settle --timeout=30 || true

# The old disk gets an XFS filesystem with a marker file, then stays unmounted.
sudo mkfs.xfs -f -L OLDCARGO "$OLD_DISK"
sudo mkdir -p /mnt/lab091-seed
sudo mount "$OLD_DISK" /mnt/lab091-seed
echo "manifest-intact" | sudo tee /mnt/lab091-seed/manifest.txt >/dev/null
sync
sudo umount /mnt/lab091-seed
sudo rmdir /mnt/lab091-seed
ASTRONA_STUDENT_SCRIPT
