#!/usr/bin/env bash
# Bootstrap: builds vg_resize/lv_data at 300M, ext4, mounted with a
# sample file. The GRADED task is growing then correctly shrinking it,
# not building it, so that part is done here.
set -eu

DISK=/dev/disk/by-id/virtio-lab035-a
for i in $(seq 1 30); do
  [ -e "$DISK" ] && break
  sleep 1
done
sudo udevadm settle --timeout=30 || true

sudo pvcreate "$DISK"
sudo vgcreate vg_resize "$DISK"
sudo lvcreate -L 300M -n lv_data vg_resize

sudo mkfs.ext4 -q /dev/vg_resize/lv_data
sudo mkdir -p /mnt/resize-data
sudo mount /dev/vg_resize/lv_data /mnt/resize-data

sudo tee /mnt/resize-data/marker.txt > /dev/null <<'EOF'
resize marker: this file must survive both the grow and the shrink.
EOF
