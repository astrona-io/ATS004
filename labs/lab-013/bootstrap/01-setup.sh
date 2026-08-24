#!/usr/bin/env bash
set -eu

DEV=/dev/disk/by-id/virtio-lab013-corrupt

for i in $(seq 1 30); do
  [ -e "$DEV" ] && break
  sleep 1
done

sudo udevadm settle --timeout=30 || true

sudo mkfs.ext4 -F "$DEV"

sudo mkdir -p /tmp/corrupt-mount
sudo mount "$DEV" /tmp/corrupt-mount
sudo touch /tmp/corrupt-mount/recovered-file-1
sudo touch /tmp/corrupt-mount/recovered-file-2
sudo umount /tmp/corrupt-mount

sudo dd if=/dev/zero of="$DEV" bs=1k count=10 seek=1024 conv=notrunc
