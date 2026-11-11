#!/usr/bin/env bash
set -euo pipefail
set +e
sudo e2fsck -y /dev/disk/by-id/virtio-lab013-corrupt
rc=$?
set -e
test "$rc" -le 1
sudo tune2fs -L RECOVERED_VOL /dev/disk/by-id/virtio-lab013-corrupt
uuid=$(sudo blkid -s UUID -o value /dev/disk/by-id/virtio-lab013-corrupt)
test -n "$uuid"
printf 'UUID=%s /mnt/recovered ext4 defaults,nofail 0 2\n' "$uuid" | sudo tee -a /etc/fstab
sudo mkdir -p /mnt/recovered
sudo systemctl daemon-reload
sudo mount /mnt/recovered
