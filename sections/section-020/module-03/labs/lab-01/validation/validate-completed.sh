#!/usr/bin/env bash
# Runs on "client". Checks the live machine.
set -u

TARGET="iqn.2026-01.io.astrona:storage.cargo"
MOUNT_POINT="/mnt/cargo"

if ! sudo iscsiadm -m session 2>/dev/null | grep -q "$TARGET"; then
  echo "FAIL: no open iSCSI session to $TARGET"
  exit 1
fi

source_device=$(findmnt -no SOURCE "$MOUNT_POINT" 2>/dev/null)
if [ -z "$source_device" ]; then
  echo "FAIL: nothing is mounted at $MOUNT_POINT"
  exit 1
fi

fs_type=$(findmnt -no FSTYPE "$MOUNT_POINT" 2>/dev/null)
if [ "$fs_type" != "ext4" ]; then
  echo "FAIL: $MOUNT_POINT has filesystem type '$fs_type', expected ext4"
  exit 1
fi

# The mounted device must be a disk that came from the iSCSI target.
real_source=$(readlink -f "$source_device")
found_iscsi_disk=0
for path_name in /dev/disk/by-path/*iscsi-"$TARGET"-lun-*; do
  [ -e "$path_name" ] || continue
  if [ "$(readlink -f "$path_name")" = "$real_source" ]; then
    found_iscsi_disk=1
  fi
done
if [ "$found_iscsi_disk" -ne 1 ]; then
  echo "FAIL: $MOUNT_POINT is not mounted from the iSCSI disk of $TARGET (source: $source_device)"
  exit 1
fi

fstab_line=$(grep -E "^[[:space:]]*UUID=[^[:space:]]+[[:space:]]+$MOUNT_POINT[[:space:]]" /etc/fstab || true)
if [ -z "$fstab_line" ]; then
  echo "FAIL: /etc/fstab has no UUID= line for $MOUNT_POINT"
  exit 1
fi
if ! echo "$fstab_line" | grep -q '_netdev'; then
  echo "FAIL: the /etc/fstab line for $MOUNT_POINT has no _netdev option"
  exit 1
fi

fstab_uuid=$(echo "$fstab_line" | sed -E 's/^[[:space:]]*UUID=([^[:space:]]+).*/\1/')
disk_uuid=$(sudo blkid -s UUID -o value "$real_source" 2>/dev/null)
if [ "$fstab_uuid" != "$disk_uuid" ]; then
  echo "FAIL: fstab UUID '$fstab_uuid' does not match the disk UUID '$disk_uuid'"
  exit 1
fi

startup=$(sudo iscsiadm -m node -T "$TARGET" -p 10.10.60.10 2>/dev/null | awk '$1=="node.startup"{print $3}')
if [ "$startup" != "automatic" ]; then
  echo "FAIL: node.startup is '$startup', expected automatic"
  exit 1
fi

echo "PASS: iSCSI disk mounted at $MOUNT_POINT as ext4, persistent in fstab with _netdev, automatic login set"
exit 0
