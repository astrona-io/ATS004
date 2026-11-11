#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -u

mount_source=$(findmnt -no SOURCE /mnt/lvm-storage 2>/dev/null)
if [ -z "$mount_source" ]; then
  echo "FAIL: nothing is mounted at /mnt/lvm-storage (step 6: 'sudo mkdir -p /mnt/lvm-storage' then 'sudo mount /dev/vg_data/lv_storage /mnt/lvm-storage')"
  exit 1
fi

if [[ "$mount_source" != *"/dev/mapper/vg_data-lv_storage"* ]] && [[ "$mount_source" != *"/dev/vg_data/lv_storage"* ]]; then
  echo "FAIL: /mnt/lvm-storage is mounted, but from '$mount_source' instead of vg_data/lv_storage"
  exit 1
fi

fstype=$(findmnt -no FSTYPE /mnt/lvm-storage 2>/dev/null)
if [ "$fstype" != "ext4" ]; then
  echo "FAIL: filesystem at /mnt/lvm-storage is '$fstype', expected ext4 (step 5: 'sudo mkfs.ext4 /dev/vg_data/lv_storage' before mounting)"
  exit 1
fi

echo "PASS: lv_storage is formatted ext4 and mounted at /mnt/lvm-storage"
exit 0
ASTRONA_STUDENT_SCRIPT
