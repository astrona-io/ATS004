#!/usr/bin/env bash
set -u

DISK="/dev/disk/by-id/virtio-lab042-swapdisk"
REAL_DEV=$(readlink -f "$DISK")

if ! swapon --show | grep -q "$REAL_DEV"; then
  echo "FAIL: $DISK ($REAL_DEV) is not active as swap"
  exit 1
fi

if ! swapon --show | grep -q "/swapfile"; then
  echo "FAIL: /swapfile is not active as swap"
  exit 1
fi

part_priority=$(cat /proc/swaps | grep "$REAL_DEV" | awk '{print $5}')
file_priority=$(cat /proc/swaps | grep "/swapfile" | awk '{print $5}')

if [ "$part_priority" != "10" ]; then
  echo "FAIL: Swap partition priority is '$part_priority', expected '10'"
  exit 1
fi

if [ "$file_priority" != "5" ]; then
  echo "FAIL: Swap file priority is '$file_priority', expected '5'"
  exit 1
fi

if ! grep -q "pri=10" /etc/fstab; then
  echo "FAIL: Priority 'pri=10' not found in /etc/fstab"
  exit 1
fi

if ! grep -q "pri=5" /etc/fstab; then
  echo "FAIL: Priority 'pri=5' not found in /etc/fstab"
  exit 1
fi

echo "PASS: Swap partition formatted, and both swap devices configured with correct scheduling priorities"
exit 0
