#!/usr/bin/env bash
set -u

DISK1=$(readlink -f /dev/disk/by-id/virtio-lab037-disk1)
DISK2=$(readlink -f /dev/disk/by-id/virtio-lab037-disk2)

if ! sudo lvs vg_pool/lv_wide >/dev/null 2>&1; then
  echo "FAIL: lv_wide does not exist yet -- fix the earlier steps before this check can pass"
  exit 1
fi

devices=$(sudo lvs --noheadings -o devices vg_pool/lv_wide 2>/dev/null)
missing=""
[[ "$devices" == *"$DISK1"* ]] || missing="$missing lab037-disk1"
[[ "$devices" == *"$DISK2"* ]] || missing="$missing lab037-disk2"

if [ -n "$missing" ]; then
  echo "FAIL: lv_wide's extents do not span both disks -- missing:$missing (Devices was: '$devices'). Check with 'sudo lvs -o +devices' -- was lv_wide sized big enough that it couldn't fit on one disk alone?"
  exit 1
fi

echo "PASS: lv_wide's extents are confirmed spread across both physical disks"
exit 0
