#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
set -eu

DISK="/dev/disk/by-id/virtio-lab015-data1"
REAL_DEV=$(readlink -f "$DISK")

fstab_line=$(awk '$1 !~ /^#/ && $2 == "/mnt/appdata" {print}' /etc/fstab)
[ "$(printf '%s\n' "$fstab_line" | wc -l)" -eq 1 ] || { echo 'FAIL: require exactly one fstab entry'; exit 1; }
[ "$(sudo blkid -s LABEL -o value "$REAL_DEV")" = APPDATA ] || { echo 'FAIL: disk label must be APPDATA'; exit 1; }
if [ -z "$fstab_line" ]; then
  echo "FAIL: no /etc/fstab entry found for /mnt/appdata"
  exit 1
fi

device_field=$(echo "$fstab_line" | awk '{print $1}')
if [[ "$device_field" != UUID=* ]]; then
  echo "FAIL: fstab entry for /mnt/appdata uses '$device_field', expected a UUID= identifier"
  exit 1
fi

fstab_uuid="${device_field#UUID=}"
real_uuid=$(sudo blkid -s UUID -o value "$REAL_DEV")
if [ "$fstab_uuid" != "$real_uuid" ]; then
  echo "FAIL: fstab UUID '$fstab_uuid' does not match the disk's actual UUID '$real_uuid'"
  exit 1
fi

options_field=$(echo "$fstab_line" | awk '{print $4}')
if [[ ",$options_field," != *,nofail,* || ",$options_field," != *,noatime,* ]]; then
  echo "FAIL: fstab options '$options_field' must include nofail and noatime"
  exit 1
fi

dump_field=$(echo "$fstab_line" | awk '{print $5}')
pass_field=$(echo "$fstab_line" | awk '{print $6}')
if [ "$dump_field" != "0" ]; then
  echo "FAIL: dump field is '$dump_field', expected 0"
  exit 1
fi
if [ "$pass_field" != "2" ]; then
  echo "FAIL: pass field is '$pass_field', expected 2"
  exit 1
fi

mount_source=$(findmnt -no SOURCE /mnt/appdata 2>/dev/null || true)
if [ -z "$mount_source" ]; then
  echo "FAIL: nothing is mounted at /mnt/appdata"
  exit 1
fi

[ "$(readlink -f "$mount_source")" = "$REAL_DEV" ] || { echo 'FAIL: mounted source is not the assigned disk'; exit 1; }

fstype=$(findmnt -no FSTYPE /mnt/appdata 2>/dev/null)
if [ "$fstype" != "ext4" ]; then
  echo "FAIL: filesystem at /mnt/appdata is '$fstype', expected ext4"
  exit 1
fi

live_options=$(findmnt -no OPTIONS /mnt/appdata 2>/dev/null)
if [[ ",$live_options," != *,noatime,* ]]; then
  echo "FAIL: live mount options '$live_options' do not include noatime"
  exit 1
fi

if ! sudo findmnt --verify --tab-file /etc/fstab; then
  echo 'FAIL: fstab verification failed'
  exit 1
fi

echo "PASS: disk formatted, UUID-keyed fstab entry correct, mounted and verified"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
