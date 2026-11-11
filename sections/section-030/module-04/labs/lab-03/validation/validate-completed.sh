#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -u

fail() { echo "FAIL: $*"; exit 1; }

A=$(readlink -f /dev/disk/by-id/virtio-lab030403-a)
B=$(readlink -f /dev/disk/by-id/virtio-lab030403-b)
C=$(readlink -f /dev/disk/by-id/virtio-lab030403-c)

# --- md0 is running again, as RAID 1, with both members active ---
[ -b /dev/md0 ] || fail "/dev/md0 does not exist -- the array is not assembled"
detail=$(sudo mdadm --detail /dev/md0 2>/dev/null)
echo "$detail" | grep -Eq 'Raid Level : raid1' || fail "/dev/md0 is not a RAID 1 array"
echo "$detail" | grep -Eq 'State : .*(clean|active)' || fail "/dev/md0 is not in a clean or active state"
echo "$detail" | grep -Eq 'Active Devices : 2' || fail "/dev/md0 does not have 2 active devices"
echo "$detail" | grep -Eq 'Failed Devices : 0' || fail "/dev/md0 has failed devices"
echo "$detail" | grep -q "$A" || fail "$A is not a member of /dev/md0"
echo "$detail" | grep -q "$B" || fail "$B is not a member of /dev/md0"

# --- The data came back mounted ---
[ "$(findmnt -no SOURCE /mnt/raid 2>/dev/null)" = "/dev/md0" ] || fail "/dev/md0 is not mounted at /mnt/raid"
grep -q "mirrored cargo manifest" /mnt/raid/manifest.txt 2>/dev/null || fail "manifest.txt is missing -- data did not survive"

# --- Disk C is clean ---
if grep -qE "$(basename "$C")" /proc/mdstat; then
  fail "$C is still part of an array listed in /proc/mdstat -- stop that array first"
fi
examine=$(sudo mdadm --examine "$C" 2>&1)
if ! echo "$examine" | grep -qi 'No md superblock detected'; then
  fail "$C still carries a RAID label (mdadm --examine finds one)"
fi

echo "PASS: md0 was reassembled with both members and its data, and the spare disk has no RAID label"
exit 0
ASTRONA_STUDENT_SCRIPT
