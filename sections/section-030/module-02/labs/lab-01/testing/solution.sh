#!/usr/bin/env bash
set -euo pipefail
sudo pvmove /dev/disk/by-id/virtio-lab032-disk1 /dev/disk/by-id/virtio-lab032-disk2

sudo vgreduce vg_migration /dev/disk/by-id/virtio-lab032-disk1

sudo pvremove /dev/disk/by-id/virtio-lab032-disk1

   sudo vgdisplay -v vg_migration
   
   cat /mnt/lvm-migration/migration-marker.txt
