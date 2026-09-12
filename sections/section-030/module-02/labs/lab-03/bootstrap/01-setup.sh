#!/usr/bin/env bash
set -eu

DISK1=/dev/disk/by-id/virtio-lab038-disk1
DISK2=/dev/disk/by-id/virtio-lab038-disk2

for dev in "$DISK1" "$DISK2"; do
  for i in $(seq 1 30); do
    [ -e "$dev" ] && break
    sleep 1
  done
done

sudo udevadm settle --timeout=30 || true

# Build the starting state on disk1 only. disk2 is deliberately left raw and
# untouched -- the student must pvcreate + vgextend it themselves; this
# bootstrap must not do that step for them.
sudo pvcreate "$DISK1"
sudo vgcreate vg_live "$DISK1"
sudo lvcreate -L 1800M -n lv_active vg_live "$DISK1"

sudo mkfs.ext4 /dev/vg_live/lv_active
sudo mkdir -p /mnt/lvm-live
sudo mount /dev/vg_live/lv_active /mnt/lvm-live

sudo tee /mnt/lvm-live/live-marker.txt > /dev/null <<'EOF'
LVM live vgextend-and-migration test. If you can read this, your migration succeeded.
EOF
