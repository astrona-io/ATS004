#!/usr/bin/env bash
# Bootstrap: builds a healthy RAID5 array across three of the four spare
# disks, with sample data mounted at /mnt/raid, and leaves the fourth disk
# raw as the replacement spare. The GRADED task is the fail/replace/rebuild
# cycle, not building the array, so that part is done here.
set -eu

A=/dev/disk/by-id/virtio-lab034-a
B=/dev/disk/by-id/virtio-lab034-b
C=/dev/disk/by-id/virtio-lab034-c
D=/dev/disk/by-id/virtio-lab034-d

for dev in "$A" "$B" "$C" "$D"; do
  for i in $(seq 1 30); do
    [ -e "$dev" ] && break
    sleep 1
  done
done

sudo udevadm settle --timeout=30 || true

yes | sudo mdadm --create /dev/md0 --level=5 --raid-devices=3 "$A" "$B" "$C"
sudo mdadm --wait /dev/md0 || true

sudo mkfs.ext4 -q /dev/md0
sudo mkdir -p /mnt/raid
sudo mount /dev/md0 /mnt/raid
echo "critical dataset row 1" | sudo tee /mnt/raid/data.txt > /dev/null

sudo mkdir -p /etc/mdadm
sudo mdadm --detail --scan | sudo tee /etc/mdadm/mdadm.conf > /dev/null

{
  echo "member1=$(readlink -f "$A")"
  echo "member2=$(readlink -f "$B")"
  echo "member3=$(readlink -f "$C")"
  echo "spare=$(readlink -f "$D")"
} | sudo tee /etc/lab034-raid > /dev/null
