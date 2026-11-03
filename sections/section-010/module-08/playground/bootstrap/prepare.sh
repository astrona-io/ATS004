#!/usr/bin/env bash
# OS prep for the "Backing Up and Cloning Storage Devices" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
set -euo pipefail

SOURCE=/dev/disk/by-id/virtio-s010m08-source
CLONE=/dev/disk/by-id/virtio-s010m08-clone
for dev in "$SOURCE" "$CLONE"; do
  for _ in $(seq 1 30); do [ -e "$dev" ] && break; sleep 1; done
done
sudo udevadm settle --timeout=30 || true

if [ -e "$SOURCE" ]; then
  blkid "$SOURCE" >/dev/null 2>&1 || {
    sudo mkfs.ext4 -q -F -L SOURCEVOL "$SOURCE"
    sudo mkdir -p /mnt/playground-source
    sudo mount "$SOURCE" /mnt/playground-source
    echo "sample data for the dd clone playground" | sudo tee /mnt/playground-source/hello.txt >/dev/null
    sudo umount /mnt/playground-source
  }
else
  echo "[playground] WARNING: $SOURCE did not appear."
fi

echo "[playground] ready. Source disk (ext4, label SOURCEVOL) is commonly /dev/vdb; blank clone disk is commonly /dev/vdc."
echo "[playground] Confirm with: lsblk"
