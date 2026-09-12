#!/usr/bin/env bash
set -u

DISK=$(readlink -f /dev/disk/by-id/virtio-lab031-disk1)

if ! sudo pvs | grep -qE "$DISK|lab031-disk1"; then
  echo "FAIL: no LVM Physical Volume found on $DISK (lab031-disk1) -- step 2: run 'sudo pvcreate' on it first"
  exit 1
fi

echo "PASS: $DISK (lab031-disk1) is initialised as an LVM Physical Volume"
exit 0
