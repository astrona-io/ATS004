#!/usr/bin/env bash
set -euo pipefail
sudo umount /mnt/raid
sudo mdadm --stop /dev/md0
sudo mdadm --assemble /dev/md0 /dev/disk/by-id/virtio-lab030403-a /dev/disk/by-id/virtio-lab030403-b
sudo mount /dev/md0 /mnt/raid
sudo mdadm --zero-superblock /dev/disk/by-id/virtio-lab030403-c
