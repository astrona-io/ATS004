#!/usr/bin/env bash
set -euo pipefail
sudo mkfs.ext4 /dev/disk/by-id/virtio-lab010-scratch
sudo mkdir -p /mnt/backup-black
sudo mount /dev/disk/by-id/virtio-lab010-scratch /mnt/backup-black
sudo touch /mnt/backup-black/completed
sudo find /mnt/backup-blue/.trash -mindepth 1 -delete
sudo systemctl stop dark-matter-v2
sudo umount /mnt/backup-red
