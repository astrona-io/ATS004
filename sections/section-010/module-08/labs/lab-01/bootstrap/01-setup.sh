#!/usr/bin/env bash
set -eu

SOURCE=/dev/disk/by-id/virtio-lab018-source
CLONE=/dev/disk/by-id/virtio-lab018-clone

for dev in "$SOURCE" "$CLONE"; do
  for i in $(seq 1 30); do
    [ -e "$dev" ] && break
    sleep 1
  done
done

sudo udevadm settle --timeout=30 || true

# Seed the source disk with a filesystem and recognizable sample data.
# The clone disk is left completely raw — cloning it is the graded task.
sudo mkfs.ext4 -F -L SOURCEVOL "$SOURCE"

sudo mkdir -p /mnt/lab018-source
sudo mount "$SOURCE" /mnt/lab018-source
echo "sample data for lab018 dd clone" | sudo tee /mnt/lab018-source/hello.txt > /dev/null
sudo umount /mnt/lab018-source
