#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Bootstrap: a healthy RAID 1 array /dev/md0 on disks a and b (ext4, mounted
# at /mnt/raid, with one file), and disk c holding the leftover label of a
# retired one-disk array. The graded task is stop / reassemble / wipe.
set -eu

A=/dev/disk/by-id/virtio-lab030403-a
B=/dev/disk/by-id/virtio-lab030403-b
C=/dev/disk/by-id/virtio-lab030403-c

for dev in "$A" "$B" "$C"; do
  for _ in $(seq 1 30); do
    [ -e "$dev" ] && break
    sleep 1
  done
done
sudo udevadm settle --timeout=30 || true

# Leftover label on disk C: build a throw-away array on it, then stop it.
# Stopping an array does not erase the label on its members.
yes | sudo mdadm --create /dev/md9 --run --level=1 --raid-devices=2 --metadata=1.2 "$C" missing
sudo mdadm --stop /dev/md9

# The healthy array on A and B.
yes | sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 --metadata=1.2 "$A" "$B"
sudo mdadm --wait /dev/md0 || true
sudo mkfs.ext4 -q /dev/md0
sudo mkdir -p /mnt/raid
sudo mount /dev/md0 /mnt/raid
echo "mirrored cargo manifest" | sudo tee /mnt/raid/manifest.txt > /dev/null
sync
ASTRONA_STUDENT_SCRIPT
