#!/usr/bin/env bash
set -euo pipefail
sudo mdadm --create /dev/md0 --run --level=5 --raid-devices=3 /dev/disk/by-id/virtio-lab033-a /dev/disk/by-id/virtio-lab033-b /dev/disk/by-id/virtio-lab033-c
sudo mdadm --wait /dev/md0
sudo mkfs.ext4 /dev/md0
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
sudo update-initramfs -u
uuid=$(sudo blkid -s UUID -o value /dev/md0)
test -n "$uuid"
printf 'UUID=%s /mnt/raid-data ext4 defaults,nofail 0 2\n' "$uuid" | sudo tee -a /etc/fstab
sudo mkdir -p /mnt/raid-data
sudo systemctl daemon-reload
sudo mount /mnt/raid-data
