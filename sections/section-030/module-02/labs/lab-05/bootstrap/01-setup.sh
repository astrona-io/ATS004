#!/usr/bin/env bash
set -eu

DISK1=/dev/disk/by-id/virtio-lab086-disk1

for i in $(seq 1 30); do
  [ -e "$DISK1" ] && break
  sleep 1
done

sudo udevadm settle --timeout=30 || true

sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq xfsprogs

sudo pvcreate "$DISK1"
sudo vgcreate vg_xfs "$DISK1"
sudo lvcreate -L 800M -n lv_xfs vg_xfs

sudo mkfs.xfs /dev/vg_xfs/lv_xfs
sudo mkdir -p /mnt/lvm-xfs
sudo mount /dev/vg_xfs/lv_xfs /mnt/lvm-xfs

sudo tee /mnt/lvm-xfs/xfs-marker.txt > /dev/null <<'EOF'
LVM XFS grow test. If you can read this, the growth preserved existing data.
EOF
