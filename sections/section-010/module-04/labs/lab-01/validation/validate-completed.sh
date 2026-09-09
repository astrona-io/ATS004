#!/usr/bin/env bash
set -u

DISK="/dev/disk/by-id/virtio-lab013-corrupt"
REAL_DEV=$(readlink -f "$DISK")

mount_source=$(findmnt -no SOURCE /mnt/recovered 2>/dev/null)
if [ -z "$mount_source" ]; then
  echo "FAIL: nothing is mounted at /mnt/recovered"
  exit 1
fi

LABEL=$(sudo blkid -s LABEL -o value "$REAL_DEV")
if [ "$LABEL" != "RECOVERED_VOL" ]; then
  echo "FAIL: Filesystem label is '$LABEL', expected 'RECOVERED_VOL'"
  exit 1
fi

UUID=$(sudo blkid -s UUID -o value "$REAL_DEV")
if ! grep -q "$UUID" /etc/fstab; then
  echo "FAIL: UUID '$UUID' not found in /etc/fstab"
  exit 1
fi

if ! grep -E "^\s*UUID=$UUID" /etc/fstab | grep -q "/mnt/recovered"; then
  echo "FAIL: No fstab entry found mounting UUID '$UUID' to /mnt/recovered"
  exit 1
fi

echo "PASS: Filesystem repaired, labeled, and persistently mounted via UUID"
exit 0
