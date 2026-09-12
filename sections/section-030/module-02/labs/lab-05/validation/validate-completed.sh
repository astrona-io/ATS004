#!/usr/bin/env bash
set -u

if ! sudo lvs vg_xfs/lv_xfs >/dev/null 2>&1; then
  echo "FAIL: Logical Volume vg_xfs/lv_xfs not found"
  exit 1
fi

size_raw=$(sudo lvs --noheadings --units m --nosuffix -o lv_size vg_xfs/lv_xfs 2>/dev/null | tr -d ' ')
size_int=${size_raw%.*}
if [ -z "$size_int" ] || [ "$size_int" -lt 1150 ] || [ "$size_int" -gt 1250 ]; then
  echo "FAIL: lv_xfs size is '${size_raw}M', expected roughly 1200M (800M + 400M grow)"
  exit 1
fi

fstype=$(findmnt -no FSTYPE /mnt/lvm-xfs 2>/dev/null)
if [ "$fstype" != "xfs" ]; then
  echo "FAIL: Filesystem at /mnt/lvm-xfs is '$fstype', expected xfs"
  exit 1
fi

# Confirm the filesystem itself was actually grown, not just the block device.
fs_blocks=$(sudo xfs_info /mnt/lvm-xfs 2>/dev/null | awk -F'[=, ]+' '/^data/{for(i=1;i<=NF;i++) if ($i=="blocks") print $(i+1)}')
if [ -z "$fs_blocks" ] || [ "$fs_blocks" -lt 300000 ]; then
  echo "FAIL: XFS filesystem does not appear to have been grown (data blocks: '${fs_blocks:-unknown}')"
  exit 1
fi

if ! grep -q "LVM XFS grow test" /mnt/lvm-xfs/xfs-marker.txt 2>/dev/null; then
  echo "FAIL: xfs-marker.txt is missing or unreadable -- data did not survive the grow"
  exit 1
fi

echo "PASS: lv_xfs grown to ~1200M and the XFS filesystem grew to match, data intact"
exit 0
