#!/usr/bin/env bash
set -u

DISK="/dev/disk/by-id/virtio-lab011-raw"

if [ ! -b "$DISK" ]; then
  echo "FAIL: target disk not found"
  exit 1
fi

REAL_DEV=$(readlink -f "$DISK")

LABEL=$(sudo parted -s "$REAL_DEV" print | grep -i "Partition Table" | cut -d: -f2 | xargs)
if [ "$LABEL" != "gpt" ]; then
  echo "FAIL: Partition table is '$LABEL', expected 'gpt'"
  exit 1
fi

if [ ! -b "${REAL_DEV}1" ] && [ ! -b "${REAL_DEV}p1" ]; then
  echo "FAIL: Partition 1 does not exist"
  exit 1
fi

START_SECTOR=$(sudo fdisk -l "$REAL_DEV" | grep "${REAL_DEV}" | grep -E "(1|p1)" | awk '{print $2}')
if [ "$START_SECTOR" != "2048" ]; then
  echo "FAIL: Partition does not start at sector 2048 (current start: $START_SECTOR)"
  exit 1
fi

echo "PASS: GPT partition table initialized and aligned partition created successfully"
exit 0
