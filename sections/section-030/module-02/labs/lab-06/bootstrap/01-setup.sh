#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Bootstrap: builds vg_data on one disk with a 500M ext4 volume lv_reports,
# mounted by hand at /mnt/reports with one file on it. No /etc/fstab line yet.
# Making it persistent and growing it are the graded tasks.
set -eu

DISK1=/dev/disk/by-id/virtio-lab030206-disk1

for _ in $(seq 1 30); do
  [ -e "$DISK1" ] && break
  sleep 1
done
sudo udevadm settle --timeout=30 || true

sudo pvcreate -ff -y "$DISK1"
sudo vgcreate vg_data "$DISK1"
sudo lvcreate -y -L 500M -n lv_reports vg_data
sudo mkfs.ext4 -q /dev/vg_data/lv_reports
sudo mkdir -p /mnt/reports
sudo mount /dev/vg_data/lv_reports /mnt/reports
echo "Monthly reports. Still here after the grow." | sudo tee /mnt/reports/reports-marker.txt > /dev/null
ASTRONA_STUDENT_SCRIPT
