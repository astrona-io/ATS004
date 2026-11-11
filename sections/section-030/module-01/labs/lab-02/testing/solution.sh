#!/usr/bin/env bash
set -euo pipefail
sudo pvcreate /dev/disk/by-id/virtio-lab037-disk1 /dev/disk/by-id/virtio-lab037-disk2
sudo vgcreate vg_pool /dev/disk/by-id/virtio-lab037-disk1 /dev/disk/by-id/virtio-lab037-disk2
sudo lvcreate --yes -L 1500M -n lv_wide vg_pool
sudo mkfs.ext4 /dev/vg_pool/lv_wide
sudo mkdir -p /mnt/lvm-wide
sudo mount /dev/vg_pool/lv_wide /mnt/lvm-wide
