#!/usr/bin/env bash
set -u

if [ ! -b "/dev/mapper/secure_volume" ]; then
  echo "FAIL: /dev/mapper/secure_volume does not exist"
  exit 1
fi

mount_source=$(findmnt -no SOURCE /mnt/secure-data 2>/dev/null)
if [ "$mount_source" != "/dev/mapper/secure_volume" ]; then
  echo "FAIL: Expected /dev/mapper/secure_volume mounted at /mnt/secure-data, found '$mount_source'"
  exit 1
fi

fstype=$(findmnt -no FSTYPE /mnt/secure-data 2>/dev/null)
if [ "$fstype" != "ext4" ]; then
  echo "FAIL: Filesystem type at /mnt/secure-data is '$fstype', expected ext4"
  exit 1
fi

if [ ! -f "/mnt/secure-data/sealed" ]; then
  echo "FAIL: Marker file /mnt/secure-data/sealed is missing"
  exit 1
fi

if ! sudo cryptsetup status secure_volume >/dev/null 2>&1; then
  echo "FAIL: cryptsetup status secure_volume failed"
  exit 1
fi

echo "PASS: LUKS container configured, formatted, mounted, and verified successfully"
exit 0
