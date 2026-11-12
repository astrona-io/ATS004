#!/usr/bin/env bash
set -euo pipefail
sudo mkfs.btrfs -L VAULT /dev/disk/by-id/virtio-lab091-btrfs
sudo mkdir -p /mnt/vault-top
sudo mount /dev/disk/by-id/virtio-lab091-btrfs /mnt/vault-top
sudo btrfs subvolume create /mnt/vault-top/data
uuid=$(sudo blkid -s UUID -o value /dev/disk/by-id/virtio-lab091-btrfs)
test -n "$uuid"
printf 'UUID=%s /srv/vault btrfs defaults,subvol=data 0 2\n' "$uuid" | sudo tee -a /etc/fstab
sudo mkdir -p /srv/vault
sudo systemctl daemon-reload
sudo mount /srv/vault
printf '%s
' 'cargo list' | sudo tee /srv/vault/cargo.txt
sudo btrfs subvolume snapshot -r /mnt/vault-top/data /mnt/vault-top/data-snapshot
