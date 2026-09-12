#!/usr/bin/env bash
set -u

DISK1=$(readlink -f /dev/disk/by-id/virtio-lab037-disk1)
DISK2=$(readlink -f /dev/disk/by-id/virtio-lab037-disk2)

if ! sudo pvs | grep -q "$DISK1"; then
  echo "FAIL: $DISK1 is not an LVM Physical Volume"
  exit 1
fi

if ! sudo pvs | grep -q "$DISK2"; then
  echo "FAIL: $DISK2 is not an LVM Physical Volume"
  exit 1
fi

pv_count=$(sudo vgs --noheadings -o pv_count vg_pool 2>/dev/null | tr -d ' ')
if [ "$pv_count" != "2" ]; then
  echo "FAIL: vg_pool does not have exactly 2 PVs (found: '$pv_count')"
  exit 1
fi

if ! sudo lvs vg_pool/lv_wide >/dev/null 2>&1; then
  echo "FAIL: Logical Volume vg_pool/lv_wide not found"
  exit 1
fi

size_raw=$(sudo lvs --noheadings --units m --nosuffix -o lv_size vg_pool/lv_wide 2>/dev/null | tr -d ' ')
size_int=${size_raw%.*}
if [ -z "$size_int" ] || [ "$size_int" -lt 1400 ] || [ "$size_int" -gt 1600 ]; then
  echo "FAIL: lv_wide size is '${size_raw}M', expected roughly 1500M"
  exit 1
fi

mount_source=$(findmnt -no SOURCE /mnt/lvm-wide 2>/dev/null)
if [[ "$mount_source" != *"/dev/mapper/vg_pool-lv_wide"* ]] && [[ "$mount_source" != *"/dev/vg_pool/lv_wide"* ]]; then
  echo "FAIL: lv_wide is not mounted at /mnt/lvm-wide (current: '$mount_source')"
  exit 1
fi

fstype=$(findmnt -no FSTYPE /mnt/lvm-wide 2>/dev/null)
if [ "$fstype" != "ext4" ]; then
  echo "FAIL: Filesystem at /mnt/lvm-wide is '$fstype', expected ext4"
  exit 1
fi

devices=$(sudo lvs --noheadings -o devices vg_pool/lv_wide 2>/dev/null)
if [[ "$devices" != *"$DISK1"* ]] || [[ "$devices" != *"$DISK2"* ]]; then
  echo "FAIL: lv_wide's extents do not span both physical disks (Devices: '$devices')"
  exit 1
fi

echo "PASS: vg_pool pools both disks and lv_wide's extents span both of them"
exit 0
