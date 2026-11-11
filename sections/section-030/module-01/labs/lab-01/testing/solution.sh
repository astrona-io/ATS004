#!/usr/bin/env bash
set -euo pipefail
sudo pvcreate /dev/disk/by-id/virtio-lab031-disk1
sudo vgcreate vg_data /dev/disk/by-id/virtio-lab031-disk1
sudo lvcreate --yes -L 500M -n lv_storage vg_data
sudo mkfs.ext4 /dev/vg_data/lv_storage
sudo mkdir -p /mnt/lvm-storage
sudo mount /dev/vg_data/lv_storage /mnt/lvm-storage
