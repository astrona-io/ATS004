#!/usr/bin/env bash
# OS prep for the "RAID Maintenance and Recovery" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
#
# Builds a realistic starting state:
#   - /dev/md0 : RAID5 across three spare disks
#   - ext4 filesystem on it, mounted at /mnt/raid with sample data
#   - the 4th spare disk left RAW, to act as the replacement
# So --fail / --remove / --add / --grow all have something real to act on.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

A=/dev/disk/by-id/virtio-s090m02-a
B=/dev/disk/by-id/virtio-s090m02-b
C=/dev/disk/by-id/virtio-s090m02-c
D=/dev/disk/by-id/virtio-s090m02-d   # raw spare

for _ in $(seq 1 30); do
  [ -e "$A" ] && [ -e "$B" ] && [ -e "$C" ] && [ -e "$D" ] && break; sleep 1
done
sudo udevadm settle --timeout=30 || true

# Clean slate in case the environment is being re-used.
sudo umount /mnt/raid 2>/dev/null || true
sudo mdadm --stop /dev/md0 2>/dev/null || true
for d in "$A" "$B" "$C" "$D"; do
  sudo mdadm --zero-superblock "$d" 2>/dev/null || true
  sudo wipefs -a "$d" || true
done

yes | sudo mdadm --create /dev/md0 --level=5 --raid-devices=3 "$A" "$B" "$C"
# Wait for the initial resync so the array starts clean.
sudo mdadm --wait /dev/md0 || true
sudo mkfs.ext4 -q /dev/md0
sudo mkdir -p /mnt/raid
sudo mount /dev/md0 /mnt/raid
echo "critical dataset row 1" | sudo tee /mnt/raid/data.txt >/dev/null
sudo mkdir -p /mnt/raid/archive
echo "archived row" | sudo tee /mnt/raid/archive/old.txt >/dev/null

sudo mkdir -p /etc/mdadm
sudo mdadm --detail --scan | sudo tee /etc/mdadm/mdadm.conf >/dev/null

# Record which kernel device is which, so the chapter does not have to guess.
{
  echo "member1=$(readlink -f "$A")"
  echo "member2=$(readlink -f "$B")"
  echo "member3=$(readlink -f "$C")"
  echo "spare=$(readlink -f "$D")   # raw replacement disk, not in the array"
} | sudo tee /etc/playground-raid >/dev/null

echo "[playground] ready:"
cat /etc/playground-raid
echo "  /dev/md0 = RAID5 on member1..3, ext4 mounted at /mnt/raid"
