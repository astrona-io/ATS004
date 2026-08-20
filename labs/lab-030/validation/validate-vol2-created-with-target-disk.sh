#!/usr/bin/env bash
# Confirms vol2 exists and the "lab030-b" disk is its PV. Resolved via
# /dev/disk/by-id/virtio-<serial> instead of a raw /dev/vdX letter, since
# astrona-cli doesn't guarantee extraDisks land on any particular letter.

set -u

DISK=/dev/disk/by-id/virtio-lab030-b

if ! sudo vgs vol2 >/dev/null 2>&1; then
  echo "FAIL: vol2 created - volume group 'vol2' does not exist"
  exit 1
fi

if [[ ! -e "$DISK" ]]; then
  echo "FAIL: vol2 created - $DISK not found"
  exit 1
fi

vg=$(sudo pvs --noheadings -o vg_name "$DISK" 2>/dev/null | tr -d '[:space:]')

if [[ "$vg" != "vol2" ]]; then
  echo "FAIL: vol2 created - $DISK is not a member of vol2 (found VG: '${vg:-none}')"
  exit 1
fi

echo "PASS: vol2 exists with $DISK as its physical volume"
exit 0
