#!/usr/bin/env bash
set -u

mount_source=$(findmnt -no SOURCE /mnt/lvm-wide 2>/dev/null)
if [ -z "$mount_source" ]; then
  echo "FAIL: nothing is mounted at /mnt/lvm-wide (step 5: 'sudo mkdir -p /mnt/lvm-wide' then 'sudo mount /dev/vg_pool/lv_wide /mnt/lvm-wide')"
  exit 1
fi

if [[ "$mount_source" != *"/dev/mapper/vg_pool-lv_wide"* ]] && [[ "$mount_source" != *"/dev/vg_pool/lv_wide"* ]]; then
  echo "FAIL: /mnt/lvm-wide is mounted, but from '$mount_source' instead of vg_pool/lv_wide"
  exit 1
fi

fstype=$(findmnt -no FSTYPE /mnt/lvm-wide 2>/dev/null)
if [ "$fstype" != "ext4" ]; then
  echo "FAIL: filesystem at /mnt/lvm-wide is '$fstype', expected ext4 (step 4: 'sudo mkfs.ext4 /dev/vg_pool/lv_wide' before mounting)"
  exit 1
fi

echo "PASS: lv_wide is formatted ext4 and mounted at /mnt/lvm-wide"
exit 0
