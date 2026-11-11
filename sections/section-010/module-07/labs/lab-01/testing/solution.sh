#!/usr/bin/env bash
set -euo pipefail
sudo mkfs.vfat -F 32 -n USBDATA /dev/disk/by-id/virtio-lab017-media
sudo mkdir -p /mnt/usbdata
sudo mount -o uid=$(id -u),gid=$(id -g),umask=022 /dev/disk/by-id/virtio-lab017-media /mnt/usbdata
touch /mnt/usbdata/proof.txt
