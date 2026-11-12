#!/usr/bin/env bash
set -euo pipefail
sudo mkswap /dev/disk/by-id/virtio-lab042-swapdisk
uuid=$(sudo blkid -s UUID -o value /dev/disk/by-id/virtio-lab042-swapdisk)
printf 'UUID=%s none swap sw,pri=10 0 0
' "$uuid" | sudo tee -a /etc/fstab
sudo swapon -a
