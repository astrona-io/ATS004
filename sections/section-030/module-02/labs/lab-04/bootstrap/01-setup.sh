#!/usr/bin/env bash
set -eu

A=/dev/disk/by-id/virtio-lab039-disk1
B=/dev/disk/by-id/virtio-lab039-disk2
C=/dev/disk/by-id/virtio-lab039-disk3

for dev in "$A" "$B" "$C"; do
  for i in $(seq 1 30); do
    [ -e "$dev" ] && break
    sleep 1
  done
done

sudo udevadm settle --timeout=30 || true

sudo pvcreate "$A" "$B" "$C"
sudo vgcreate vg_split "$A" "$B" "$C"

# Force the LV's 900M across all three disks in equal 300M shares, so the
# student starts from a genuinely mixed layout instead of one full disk.
sudo lvcreate -n lv_data -L 300M vg_split "$A"
sudo lvextend -L +300M /dev/vg_split/lv_data "$B"
sudo lvextend -L +300M /dev/vg_split/lv_data "$C"

sudo mkfs.ext4 /dev/vg_split/lv_data
sudo mkdir -p /mnt/lvm-split
sudo mount /dev/vg_split/lv_data /mnt/lvm-split

sudo tee /mnt/lvm-split/split-marker.txt > /dev/null <<'EOF'
LVM mixed-extent PV removal test. If you can read this, disk2 was safely removed.
EOF
