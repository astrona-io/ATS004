#!/usr/bin/env bash
# Bootstrap: builds a healthy RAID5 array across three of the four spare
# disks, with sample data mounted at /mnt/raid-grow, and leaves the fourth
# disk raw as the growth spare. The GRADED task is growing the array and
# configuring monitoring, not building it, so that part is done here.
set -eu

A=/dev/disk/by-id/virtio-lab036-a
B=/dev/disk/by-id/virtio-lab036-b
C=/dev/disk/by-id/virtio-lab036-c
D=/dev/disk/by-id/virtio-lab036-d

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
sudo mkdir -p /mnt/raid-grow
sudo mount /dev/md0 /mnt/raid-grow
echo "growth test dataset" | sudo tee /mnt/raid-grow/data.txt > /dev/null

sudo mkdir -p /etc/mdadm
sudo mdadm --detail --scan | sudo tee /etc/mdadm/mdadm.conf > /dev/null

{
  echo "member1=$(readlink -f "$A")"
  echo "member2=$(readlink -f "$B")"
  echo "member3=$(readlink -f "$C")"
  echo "spare=$(readlink -f "$D")"
} | sudo tee /etc/lab036-raid > /dev/null
