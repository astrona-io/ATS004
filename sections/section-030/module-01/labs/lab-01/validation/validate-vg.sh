#!/usr/bin/env bash
set -u

DISK=$(readlink -f /dev/disk/by-id/virtio-lab031-disk1)

if ! sudo vgs vg_data >/dev/null 2>&1; then
  echo "FAIL: Volume Group 'vg_data' not found (step 3: run 'sudo vgcreate vg_data <pv>')"
  exit 1
fi

if ! sudo vgdisplay -v vg_data 2>/dev/null | grep -qE "$DISK|lab031-disk1"; then
  echo "FAIL: vg_data exists but does not contain $DISK (lab031-disk1) -- wrong device passed to vgcreate?"
  exit 1
fi

echo "PASS: Volume Group vg_data exists and pools $DISK (lab031-disk1)"
exit 0
