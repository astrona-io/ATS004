#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -u

NEW_DEV=$(readlink -f /dev/disk/by-id/virtio-lab091-new)
OLD_DEV=$(readlink -f /dev/disk/by-id/virtio-lab091-old)

new_type=$(sudo blkid -s TYPE -o value "$NEW_DEV" 2>/dev/null)
if [ "$new_type" != "xfs" ]; then
  echo "FAIL: filesystem type on $NEW_DEV is '$new_type', expected 'xfs'"
  exit 1
fi

new_label=$(sudo blkid -s LABEL -o value "$NEW_DEV" 2>/dev/null)
if [ "$new_label" != "NEWCARGO" ]; then
  echo "FAIL: label on $NEW_DEV is '$new_label', expected 'NEWCARGO'"
  exit 1
fi

new_uuid=$(sudo blkid -s UUID -o value "$NEW_DEV" 2>/dev/null)
if ! grep -Eq "^UUID=${new_uuid}[[:space:]]+/srv/newcargo[[:space:]]+xfs[[:space:]]+[^#[:space:]]*noatime" /etc/fstab; then
  echo "FAIL: /etc/fstab has no 'UUID=$new_uuid /srv/newcargo xfs ...noatime' line"
  exit 1
fi

mount_source=$(findmnt -no SOURCE /srv/newcargo 2>/dev/null)
if [ "$mount_source" != "$NEW_DEV" ]; then
  echo "FAIL: /srv/newcargo is not mounted from $NEW_DEV (found: '$mount_source')"
  exit 1
fi

mount_type=$(findmnt -no FSTYPE /srv/newcargo 2>/dev/null)
mount_options=$(findmnt -no OPTIONS /srv/newcargo 2>/dev/null)
if [ "$mount_type" != "xfs" ] || ! echo "$mount_options" | grep -q "noatime"; then
  echo "FAIL: /srv/newcargo is '$mount_type' with options '$mount_options', expected xfs with noatime"
  exit 1
fi

old_type=$(sudo blkid -s TYPE -o value "$OLD_DEV" 2>/dev/null)
old_label=$(sudo blkid -s LABEL -o value "$OLD_DEV" 2>/dev/null)
if [ "$old_type" != "xfs" ] || [ "$old_label" != "OLDCARGO" ]; then
  echo "FAIL: old disk changed (type '$old_type', label '$old_label')"
  exit 1
fi

if findmnt -rn -S "$OLD_DEV" >/dev/null 2>&1; then
  echo "FAIL: the old disk $OLD_DEV must stay unmounted"
  exit 1
fi

# Look inside the old disk read-only to prove the data is untouched.
CHECK_DIR=$(mktemp -d)
if ! sudo mount -o ro "$OLD_DEV" "$CHECK_DIR" 2>/dev/null; then
  echo "FAIL: the old disk could not be mounted read-only for the grader"
  rmdir "$CHECK_DIR"
  exit 1
fi
manifest=$(sudo cat "$CHECK_DIR/manifest.txt" 2>/dev/null)
sudo umount "$CHECK_DIR"
rmdir "$CHECK_DIR"
if [ "$manifest" != "manifest-intact" ]; then
  echo "FAIL: manifest.txt on the old disk is missing or changed"
  exit 1
fi

CHECK_FILE=/home/ubuntu/oldcargo-check.txt
if [ ! -s "$CHECK_FILE" ]; then
  echo "FAIL: $CHECK_FILE is missing or empty"
  exit 1
fi
if ! grep -q "Phase 1" "$CHECK_FILE"; then
  echo "FAIL: $CHECK_FILE does not look like xfs_repair output"
  exit 1
fi
if grep -q "Phase 5" "$CHECK_FILE" && ! grep -qi "no modify" "$CHECK_FILE"; then
  echo "FAIL: $CHECK_FILE does not show a no-modify (-n) run"
  exit 1
fi

echo "PASS: new disk is XFS NEWCARGO mounted by UUID with noatime, old disk untouched, dry-run check saved"
exit 0
ASTRONA_STUDENT_SCRIPT
