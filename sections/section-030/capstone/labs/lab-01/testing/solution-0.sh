#!/usr/bin/env bash
set -euo pipefail
sudo pvmove /dev/disk/by-id/virtio-lab030-b /dev/disk/by-id/virtio-lab030-a
sudo vgreduce vol1 /dev/disk/by-id/virtio-lab030-b
sudo pvremove /dev/disk/by-id/virtio-lab030-b
sudo vgcreate vol2 /dev/disk/by-id/virtio-lab030-b
sudo lvcreate -L 50M -n p1 vol2
sudo mkfs.ext4 /dev/vol2/p1
