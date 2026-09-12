#!/usr/bin/env bash
set -u

DISK1=$(readlink -f /dev/disk/by-id/virtio-lab038-disk1)
DISK2=$(readlink -f /dev/disk/by-id/virtio-lab038-disk2)

# disk1 must be fully retired: no longer a PV, no longer in the VG.
if sudo pvs | grep -q "$DISK1"; then
  echo "FAIL: $DISK1 is still marked as an LVM Physical Volume"
  exit 1
fi

if sudo vgdisplay -v vg_live 2>/dev/null | grep -q "$DISK1"; then
  echo "FAIL: vg_live still references $DISK1"
  exit 1
fi

# disk2 must be a PV and a member of vg_live -- this can only be true if the
# student actually ran vgextend themselves, since bootstrap never touches it.
if ! sudo pvs | grep -q "$DISK2"; then
  echo "FAIL: $DISK2 was never initialised as a Physical Volume (vgextend step skipped)"
  exit 1
fi

if ! sudo vgdisplay -v vg_live 2>/dev/null | grep -q "$DISK2"; then
  echo "FAIL: vg_live does not contain $DISK2 -- the vgextend step was skipped"
  exit 1
fi

pv_count=$(sudo vgs --noheadings -o pv_count vg_live 2>/dev/null | tr -d ' ')
if [ "$pv_count" != "1" ]; then
  echo "FAIL: vg_live should have exactly 1 PV remaining (disk2), found '$pv_count'"
  exit 1
fi

mount_source=$(findmnt -no SOURCE /mnt/lvm-live 2>/dev/null)
if [[ "$mount_source" != *"/dev/mapper/vg_live-lv_active"* ]] && [[ "$mount_source" != *"/dev/vg_live/lv_active"* ]]; then
  echo "FAIL: LVM mount is broken or missing (current: '$mount_source')"
  exit 1
fi

if ! grep -q "LVM live vgextend-and-migration test" /mnt/lvm-live/live-marker.txt 2>/dev/null; then
  echo "FAIL: live-marker.txt is missing or unreadable -- data did not survive the migration"
  exit 1
fi

echo "PASS: disk2 was added via vgextend, disk1 was fully evacuated and removed, data survived"
exit 0
