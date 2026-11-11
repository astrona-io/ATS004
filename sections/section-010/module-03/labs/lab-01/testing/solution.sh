#!/usr/bin/env bash
set -euo pipefail
printf '%s' securepassword123 | sudo cryptsetup luksFormat --batch-mode /dev/disk/by-id/virtio-lab012-raw -
printf '%s' securepassword123 | sudo cryptsetup open /dev/disk/by-id/virtio-lab012-raw secure_volume --key-file -
sudo mkfs.ext4 /dev/mapper/secure_volume
sudo mkdir -p /mnt/secure-data
sudo mount /dev/mapper/secure_volume /mnt/secure-data
sudo touch /mnt/secure-data/sealed
