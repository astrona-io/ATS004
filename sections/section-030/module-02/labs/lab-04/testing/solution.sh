#!/usr/bin/env bash
set -euo pipefail
sudo lvs -o +devices

sudo pvs -o pv_name,pv_used,pv_free

sudo pvmove /dev/disk/by-id/virtio-lab039-disk2

sudo lvs -o +devices

sudo vgreduce vg_split /dev/disk/by-id/virtio-lab039-disk2

sudo pvremove /dev/disk/by-id/virtio-lab039-disk2

sudo pvs
sudo vgs vg_split
cat /mnt/lvm-split/*.txt
