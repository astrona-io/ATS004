#!/usr/bin/env bash
set -euo pipefail
sudo dd if=/dev/zero of=/swapfile bs=1M count=2048 status=none
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo tee /tmp/swap-fstab >/dev/null <<'REFERENCE_FILE'
/swapfile none swap sw,pri=5 0 0
REFERENCE_FILE
cat /tmp/swap-fstab | sudo tee -a /etc/fstab
sudo swapon -p 5 /swapfile
sudo mkswap /dev/disk/by-id/virtio-lab040-swap
uuid=$(sudo blkid -s UUID -o value /dev/disk/by-id/virtio-lab040-swap)
printf 'UUID=%s none swap sw,pri=10 0 0\n' "$uuid" | sudo tee -a /etc/fstab
sudo swapon -a
