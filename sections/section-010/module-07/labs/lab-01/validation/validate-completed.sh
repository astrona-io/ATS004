#!/usr/bin/env bash
set -u

DISK="/dev/disk/by-id/virtio-lab017-media"
REAL_DEV=$(readlink -f "$DISK")

FSTYPE=$(sudo blkid -s TYPE -o value "$REAL_DEV" 2>/dev/null)
if [ "$FSTYPE" != "vfat" ]; then
  echo "FAIL: filesystem type on $REAL_DEV is '$FSTYPE', expected 'vfat'"
  exit 1
fi

if ! sudo file -s "$REAL_DEV" 2>/dev/null | grep -q "FAT (32 bit)"; then
  echo "FAIL: $REAL_DEV is not formatted as FAT32 (expected 'FAT (32 bit)')"
  exit 1
fi

LABEL=$(sudo blkid -s LABEL -o value "$REAL_DEV" 2>/dev/null)
if [ "$LABEL" != "USBDATA" ]; then
  echo "FAIL: volume label is '$LABEL', expected 'USBDATA'"
  exit 1
fi

mount_source=$(findmnt -no SOURCE /mnt/usbdata 2>/dev/null)
if [ "$mount_source" != "$REAL_DEV" ]; then
  echo "FAIL: /mnt/usbdata is not mounted from $REAL_DEV (found: '$mount_source')"
  exit 1
fi

STUDENT_UID=$(id -u ubuntu)
mount_options=$(findmnt -no OPTIONS /mnt/usbdata 2>/dev/null)
if ! echo "$mount_options" | grep -q "uid=$STUDENT_UID"; then
  echo "FAIL: /mnt/usbdata is not mounted with uid=$STUDENT_UID (options: '$mount_options')"
  exit 1
fi

if [ ! -f /mnt/usbdata/proof.txt ]; then
  echo "FAIL: /mnt/usbdata/proof.txt does not exist"
  exit 1
fi

FILE_UID=$(stat -c %u /mnt/usbdata/proof.txt)
if [ "$FILE_UID" != "$STUDENT_UID" ]; then
  echo "FAIL: /mnt/usbdata/proof.txt is owned by uid $FILE_UID, expected $STUDENT_UID"
  exit 1
fi

if ! sudo -u ubuntu test -w /mnt/usbdata/proof.txt; then
  echo "FAIL: ubuntu cannot write to /mnt/usbdata/proof.txt"
  exit 1
fi

echo "PASS: disk formatted FAT32, labeled USBDATA, mounted with correct uid, and writable without sudo"
exit 0
