#!/usr/bin/env bash
set -u

if ! sudo pvs | grep -q "lab031-disk1"; then
  echo "FAIL: LVM Physical Volume on lab031-disk1 not found"
  exit 1
fi

if ! sudo vgs vg_data >/dev/null 2>&1; then
  echo "FAIL: Volume Group vg_data not found"
  exit 1
fi

if ! sudo lvs vg_data/lv_storage >/dev/null 2>&1; then
  echo "FAIL: Logical Volume vg_data/lv_storage not found"
  exit 1
fi

mount_source=$(findmnt -no SOURCE /mnt/lvm-storage 2>/dev/null)
if [[ "$mount_source" != *"/dev/mapper/vg_data-lv_storage"* ]] && [[ "$mount_source" != *"/dev/vg_data/lv_storage"* ]]; then
  echo "FAIL: /dev/vg_data/lv_storage is not mounted at /mnt/lvm-storage (current: '$mount_source')"
  exit 1
fi

fstype=$(findmnt -no FSTYPE /mnt/lvm-storage 2>/dev/null)
if [ "$fstype" != "ext4" ]; then
  echo "FAIL: Filesystem at /mnt/lvm-storage is '$fstype', expected ext4"
  exit 1
fi

echo "PASS: LVM logical volume allocated, formatted, and mounted successfully"
exit 0
