#!/usr/bin/env bash
set -euo pipefail
sudo pvcreate /dev/disk/by-id/virtio-lab038-disk2

sudo vgextend vg_live /dev/disk/by-id/virtio-lab038-disk2

sudo vgs vg_live
sudo pvs

sudo pvmove /dev/disk/by-id/virtio-lab038-disk1

sudo lvs -o +devices

sudo vgreduce vg_live /dev/disk/by-id/virtio-lab038-disk1

sudo pvremove /dev/disk/by-id/virtio-lab038-disk1

sudo pvs
sudo vgdisplay -v vg_live
cat /mnt/lvm-live/*.txt
