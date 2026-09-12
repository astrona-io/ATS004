#!/usr/bin/env bash
set -u

DISK1=$(readlink -f /dev/disk/by-id/virtio-lab037-disk1)
DISK2=$(readlink -f /dev/disk/by-id/virtio-lab037-disk2)

if ! sudo pvs | grep -q "$DISK1"; then
  echo "FAIL: $DISK1 is not an LVM Physical Volume (step 1: 'sudo pvcreate' it)"
  exit 1
fi

if ! sudo pvs | grep -q "$DISK2"; then
  echo "FAIL: $DISK2 is not an LVM Physical Volume (step 1: 'sudo pvcreate' it)"
  exit 1
fi

echo "PASS: both disks are initialised as LVM Physical Volumes"
exit 0
