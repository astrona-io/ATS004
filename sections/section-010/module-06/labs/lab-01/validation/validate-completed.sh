#!/usr/bin/env bash
set -u

MOUNT_UNIT="/etc/systemd/system/srv-appdata.mount"
AUTOMOUNT_UNIT="/etc/systemd/system/srv-appdata.automount"

if [ ! -f "$MOUNT_UNIT" ]; then
  echo "FAIL: $MOUNT_UNIT does not exist"
  exit 1
fi

if ! grep -q '^Where=/srv/appdata' "$MOUNT_UNIT"; then
  echo "FAIL: $MOUNT_UNIT is missing Where=/srv/appdata"
  exit 1
fi

if ! grep -q '^Type=ext4' "$MOUNT_UNIT"; then
  echo "FAIL: $MOUNT_UNIT is missing Type=ext4"
  exit 1
fi

if [ ! -f "$AUTOMOUNT_UNIT" ]; then
  echo "FAIL: $AUTOMOUNT_UNIT does not exist"
  exit 1
fi

if ! grep -q '^Where=/srv/appdata' "$AUTOMOUNT_UNIT"; then
  echo "FAIL: $AUTOMOUNT_UNIT is missing Where=/srv/appdata"
  exit 1
fi

if ! grep -q '^TimeoutIdleSec=' "$AUTOMOUNT_UNIT"; then
  echo "FAIL: $AUTOMOUNT_UNIT is missing TimeoutIdleSec="
  exit 1
fi

enabled=$(systemctl is-enabled srv-appdata.automount 2>/dev/null)
if [ "$enabled" != "enabled" ]; then
  echo "FAIL: srv-appdata.automount is not enabled (got '$enabled')"
  exit 1
fi

# Trigger the on-demand mount.
ls /srv/appdata >/dev/null 2>&1

active=$(systemctl is-active srv-appdata.mount 2>/dev/null)
if [ "$active" != "active" ]; then
  echo "FAIL: srv-appdata.mount is not active after triggering access (got '$active')"
  exit 1
fi

fstype=$(findmnt -no FSTYPE /srv/appdata 2>/dev/null)
if [ "$fstype" != "ext4" ]; then
  echo "FAIL: /srv/appdata is mounted with fstype '$fstype', expected ext4"
  exit 1
fi

echo "PASS: native .mount/.automount units configured and on-demand trigger confirmed"
exit 0
