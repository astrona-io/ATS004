#!/usr/bin/env bash
# Confirms the "lab030-b" disk (the one bootstrap forced vol1/data1's
# extents onto) is no longer a member of vol1 (vgreduce succeeded).
# Resolved via /dev/disk/by-id/virtio-<serial> instead of a raw /dev/vdX
# letter, since astrona-cli doesn't guarantee extraDisks land on any
# particular letter.

set -u

DISK=/dev/disk/by-id/virtio-lab030-b

if [[ ! -e "$DISK" ]]; then
  echo "FAIL: target disk removed from vol1 - $DISK not found"
  exit 1
fi

vg=$(sudo pvs --noheadings -o vg_name "$DISK" 2>/dev/null | tr -d '[:space:]')

if [[ "$vg" == "vol1" ]]; then
  echo "FAIL: target disk removed from vol1 - $DISK is still a member of vol1"
  exit 1
fi

echo "PASS: $DISK is no longer a member of vol1 (current VG: '${vg:-none}')"
exit 0
