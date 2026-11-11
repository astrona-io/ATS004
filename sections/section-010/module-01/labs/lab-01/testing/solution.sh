#!/usr/bin/env bash
set -euo pipefail
sudo mkfs.ext4 /dev/disk/by-id/virtio-lab014-scratch
sudo mkdir -p /mnt/backup-black
sudo mount /dev/disk/by-id/virtio-lab014-scratch /mnt/backup-black
sudo touch /mnt/backup-black/completed
