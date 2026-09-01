#!/usr/bin/env bash
# Bootstrap: builds the starting LVM stack for the lab — vol1 spanning
# both extraDisks, with a logical volume forced onto the "lab030-b" disk
# specifically so it holds real allocated extents and pvmove has actual
# work to do before vgreduce can remove it.
#
# IMPORTANT: astrona-cli's extraDisks are NOT guaranteed to land on
# /dev/vdb/vdc -- in practice they can enumerate BEFORE the main disk, so
# a raw device-letter guess here risks running pvcreate against the VM's
# own root disk. Both disks are resolved via their `serial` (set in
# config.yaml) through the kernel's stable /dev/disk/by-id/virtio-<serial>
# path instead.

set -eu

if ! command -v pvcreate >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y lvm2
fi

A=/dev/disk/by-id/virtio-lab030-a
B=/dev/disk/by-id/virtio-lab030-b

for dev in "$A" "$B"; do
  for i in $(seq 1 30); do
    [ -e "$dev" ] && break
    sleep 1
  done
done

# by-id symlinks existing doesn't mean udev is fully done with the
# underlying device -- give it a moment to settle before pvcreate.
sudo udevadm settle --timeout=30 || true

sudo pvcreate -f "$A" "$B"
sudo vgcreate vol1 "$A" "$B"

# Force these extents onto the "lab030-b" disk specifically (not left to
# the allocator's default placement) so it genuinely has allocated
# extents for the lab's pvmove step to relocate.
sudo lvcreate -L 500M -n data1 vol1 "$B"
sudo mkfs.ext4 -q /dev/vol1/data1
sudo mkdir -p /mnt/vol1-data1
sudo mount /dev/vol1/data1 /mnt/vol1-data1
echo "seed data for vol1/data1" | sudo tee /mnt/vol1-data1/seed.txt > /dev/null
