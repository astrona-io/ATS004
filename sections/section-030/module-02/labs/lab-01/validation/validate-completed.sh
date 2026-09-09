#!/usr/bin/env bash
set -u

DISK1="/dev/disk/by-id/virtio-lab032-disk1"
REAL_DISK1=$(readlink -f "$DISK1")

if sudo pvs | grep -q "$REAL_DISK1"; then
  echo "FAIL: $DISK1 is still marked as an LVM Physical Volume"
  exit 1
fi

if sudo vgdisplay -v vg_migration 2>/dev/null | grep -q "$REAL_DISK1"; then
  echo "FAIL: vg_migration still contains $DISK1"
  exit 1
fi

mount_source=$(findmnt -no SOURCE /mnt/lvm-migration 2>/dev/null)
if [[ "$mount_source" != *"/dev/mapper/vg_migration-lv_active"* ]] && [[ "$mount_source" != *"/dev/vg_migration/lv_active"* ]]; then
  echo "FAIL: LVM mount is broken or missing"
  exit 1
fi

if ! grep -q "LVM live migration test" /mnt/lvm-migration/migration-marker.txt 2>/dev/null; then
  echo "FAIL: Migration marker file is missing or unreadable"
  exit 1
fi

echo "PASS: Online extent migration completed and Volume Group reduced successfully"
exit 0
