#!/usr/bin/env bash
set -u

DISK1=$(readlink -f /dev/disk/by-id/virtio-lab039-disk1)
DISK2=$(readlink -f /dev/disk/by-id/virtio-lab039-disk2)
DISK3=$(readlink -f /dev/disk/by-id/virtio-lab039-disk3)

# disk2 must be fully retired: no longer a PV, no longer in the VG.
if sudo pvs | grep -q "$DISK2"; then
  echo "FAIL: $DISK2 is still marked as an LVM Physical Volume"
  exit 1
fi

if sudo vgdisplay -v vg_split 2>/dev/null | grep -q "$DISK2"; then
  echo "FAIL: vg_split still references $DISK2"
  exit 1
fi

# disk1 and disk3 must still be present.
for d in "$DISK1" "$DISK3"; do
  if ! sudo pvs | grep -q "$d"; then
    echo "FAIL: $d should still be an LVM Physical Volume but is not"
    exit 1
  fi
done

pv_count=$(sudo vgs --noheadings -o pv_count vg_split 2>/dev/null | tr -d ' ')
if [ "$pv_count" != "2" ]; then
  echo "FAIL: vg_split should have exactly 2 PVs remaining, found '$pv_count'"
  exit 1
fi

size_raw=$(sudo lvs --noheadings --units m --nosuffix -o lv_size vg_split/lv_data 2>/dev/null | tr -d ' ')
size_int=${size_raw%.*}
if [ -z "$size_int" ] || [ "$size_int" -lt 850 ] || [ "$size_int" -gt 950 ]; then
  echo "FAIL: lv_data size is '${size_raw}M', expected roughly 900M (unchanged by the removal)"
  exit 1
fi

mount_source=$(findmnt -no SOURCE /mnt/lvm-split 2>/dev/null)
if [[ "$mount_source" != *"/dev/mapper/vg_split-lv_data"* ]] && [[ "$mount_source" != *"/dev/vg_split/lv_data"* ]]; then
  echo "FAIL: lv_data is not mounted at /mnt/lvm-split (current: '$mount_source')"
  exit 1
fi

if ! grep -q "LVM mixed-extent PV removal test" /mnt/lvm-split/split-marker.txt 2>/dev/null; then
  echo "FAIL: split-marker.txt is missing or unreadable -- data did not survive the removal"
  exit 1
fi

echo "PASS: disk2 evacuated and removed; disk1/disk3 kept lv_data intact at its original size"
exit 0
