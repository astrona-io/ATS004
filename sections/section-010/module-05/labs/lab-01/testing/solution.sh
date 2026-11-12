#!/usr/bin/env bash
set -euo pipefail
DEV=/dev/disk/by-id/virtio-lab015-data1
sudo mkfs.ext4 -F -L APPDATA "$DEV"
sudo mkdir -p /mnt/appdata
uuid=$(sudo blkid -s UUID -o value "$DEV")
printf 'UUID=%s /mnt/appdata ext4 defaults,nofail,noatime 0 2\n' "$uuid" | sudo tee -a /etc/fstab >/dev/null
sudo systemctl daemon-reload
sudo mount /mnt/appdata
printf 'persistent-data\n' | sudo tee /mnt/appdata/reboot-check >/dev/null
