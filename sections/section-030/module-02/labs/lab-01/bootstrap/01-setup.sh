#!/usr/bin/env bash
set -eu

DISK1=/dev/disk/by-id/virtio-lab032-disk1
DISK2=/dev/disk/by-id/virtio-lab032-disk2

for dev in "$DISK1" "$DISK2"; do
  for i in $(seq 1 30); do
    [ -e "$dev" ] && break
    sleep 1
  done
done

sudo udevadm settle --timeout=30 || true

sudo pvcreate "$DISK1" "$DISK2"
sudo vgcreate vg_migration "$DISK1" "$DISK2"
sudo lvcreate -L 500M -n lv_active vg_migration "$DISK1"

sudo mkfs.ext4 /dev/vg_migration/lv_active
sudo mkdir -p /mnt/lvm-migration
sudo mount /dev/vg_migration/lv_active /mnt/lvm-migration

sudo tee /mnt/lvm-migration/migration-marker.txt > /dev/null <<'EOF'
LVM live migration test. If you can read this, your migration succeeded.
EOF
