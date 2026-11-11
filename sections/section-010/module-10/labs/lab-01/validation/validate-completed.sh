#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -u

DISK="/dev/disk/by-id/virtio-lab091-btrfs"
REAL_DEV=$(readlink -f "$DISK")
MOUNT_POINT="/srv/vault"

FSTYPE=$(sudo blkid -s TYPE -o value "$REAL_DEV" 2>/dev/null)
if [ "$FSTYPE" != "btrfs" ]; then
  echo "FAIL: filesystem type on $REAL_DEV is '$FSTYPE', expected 'btrfs'"
  exit 1
fi

LABEL=$(sudo blkid -s LABEL -o value "$REAL_DEV" 2>/dev/null)
if [ "$LABEL" != "VAULT" ]; then
  echo "FAIL: label is '$LABEL', expected 'VAULT'"
  exit 1
fi

UUID_VALUE=$(sudo blkid -s UUID -o value "$REAL_DEV" 2>/dev/null)

mount_source=$(findmnt -no SOURCE "$MOUNT_POINT" 2>/dev/null)
case "$mount_source" in
  "$REAL_DEV"*) ;;
  *) echo "FAIL: $MOUNT_POINT is not mounted from $REAL_DEV (found: '$mount_source')"; exit 1 ;;
esac

mount_options=$(findmnt -no OPTIONS "$MOUNT_POINT" 2>/dev/null)
if ! echo "$mount_options" | grep -Eq 'subvol=/?data(,|$)'; then
  echo "FAIL: $MOUNT_POINT is not mounted with subvol=data (options: '$mount_options')"
  exit 1
fi

if ! grep -Eq "^UUID=${UUID_VALUE}[[:space:]]+${MOUNT_POINT}[[:space:]]+btrfs[[:space:]]+[^#]*subvol=/?data" /etc/fstab; then
  echo "FAIL: /etc/fstab has no UUID=$UUID_VALUE line for $MOUNT_POINT with subvol=data"
  exit 1
fi

if [ ! -f "$MOUNT_POINT/cargo.txt" ]; then
  echo "FAIL: $MOUNT_POINT/cargo.txt does not exist"
  exit 1
fi

TOP=$(mktemp -d)
cleanup() { sudo umount "$TOP" 2>/dev/null; rmdir "$TOP" 2>/dev/null; }
trap cleanup EXIT

if ! sudo mount -o subvolid=5 "$REAL_DEV" "$TOP" 2>/dev/null; then
  echo "FAIL: could not mount the top of the Btrfs filesystem to inspect it"
  exit 1
fi

subvolume_list=$(sudo btrfs subvolume list "$TOP" 2>/dev/null)
if ! echo "$subvolume_list" | grep -Eq 'path data$'; then
  echo "FAIL: subvolume 'data' not found at the top of the filesystem"
  exit 1
fi
if ! echo "$subvolume_list" | grep -Eq 'path data-snapshot$'; then
  echo "FAIL: snapshot 'data-snapshot' not found at the top of the filesystem"
  exit 1
fi

if ! sudo btrfs property get -ts "$TOP/data-snapshot" ro 2>/dev/null | grep -q "ro=true"; then
  echo "FAIL: data-snapshot is not read-only"
  exit 1
fi

if [ ! -f "$TOP/data-snapshot/cargo.txt" ]; then
  echo "FAIL: data-snapshot does not contain cargo.txt (take the snapshot after creating the file)"
  exit 1
fi

echo "PASS: Btrfs VAULT disk, subvolume data mounted persistently by UUID, read-only snapshot taken"
exit 0
ASTRONA_STUDENT_SCRIPT
