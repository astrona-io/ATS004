#!/usr/bin/env bash
set -euo pipefail
sudo mkfs.xfs -L NEWCARGO /dev/disk/by-id/virtio-lab091-new
uuid=$(sudo blkid -s UUID -o value /dev/disk/by-id/virtio-lab091-new)
test -n "$uuid"
printf 'UUID=%s /srv/newcargo xfs defaults,noatime 0 2\n' "$uuid" | sudo tee -a /etc/fstab
sudo mkdir -p /srv/newcargo
sudo systemctl daemon-reload
sudo mount /srv/newcargo
sudo mkdir -p /home/ubuntu
sudo xfs_repair -n /dev/disk/by-id/virtio-lab091-old 2>&1 | sudo tee /home/ubuntu/oldcargo-check.txt
