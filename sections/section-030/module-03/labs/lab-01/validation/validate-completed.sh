#!/usr/bin/env bash
set -u

if ! sudo mdadm --detail /dev/md0 >/dev/null 2>&1; then
  echo "FAIL: /dev/md0 does not exist"
  exit 1
fi

detail=$(sudo mdadm --detail /dev/md0)

if ! echo "$detail" | grep -q "Raid Level : raid5"; then
  echo "FAIL: /dev/md0 is not a RAID 5 array"
  exit 1
fi

active=$(echo "$detail" | grep "Active Devices" | grep -o '[0-9]*')
if [ "$active" != "3" ]; then
  echo "FAIL: expected 3 active devices, found $active"
  exit 1
fi

if ! grep -qE 'raid5.*\[3/3\]' /proc/mdstat; then
  echo "FAIL: /proc/mdstat does not show a healthy [3/3] raid5 array"
  exit 1
fi

mount_source=$(findmnt -no SOURCE /mnt/raid-data 2>/dev/null)
if [[ "$mount_source" != *"/dev/md0"* ]] && [[ "$mount_source" != *"/dev/md/"* ]]; then
  echo "FAIL: /dev/md0 is not mounted at /mnt/raid-data (current: '$mount_source')"
  exit 1
fi

fstype=$(findmnt -no FSTYPE /mnt/raid-data 2>/dev/null)
if [ "$fstype" != "ext4" ]; then
  echo "FAIL: Filesystem at /mnt/raid-data is '$fstype', expected ext4"
  exit 1
fi

if ! grep -q '^ARRAY' /etc/mdadm/mdadm.conf 2>/dev/null; then
  echo "FAIL: /etc/mdadm/mdadm.conf has no ARRAY line"
  exit 1
fi

fstab_line=$(grep '/mnt/raid-data' /etc/fstab || true)
if [ -z "$fstab_line" ]; then
  echo "FAIL: no /etc/fstab entry for /mnt/raid-data"
  exit 1
fi
if [[ "$fstab_line" != UUID=* ]]; then
  echo "FAIL: /etc/fstab entry for /mnt/raid-data is not keyed by UUID= (found: '$fstab_line')"
  exit 1
fi

echo "PASS: RAID 5 array created, formatted, mounted, and made persistent"
exit 0
