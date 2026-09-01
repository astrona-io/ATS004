#!/usr/bin/env bash
set -u

mount_type=$(findmnt -no FSTYPE /mnt/sshfs-share 2>/dev/null)
if [[ "$mount_type" != *"sshfs"* ]] && [[ "$mount_type" != *"fuse"* ]]; then
  echo "FAIL: Expected sshfs or fuse mount at /mnt/sshfs-share, found '$mount_type'"
  exit 1
fi

if [ ! -f "/mnt/sshfs-share/welcome.txt" ]; then
  echo "FAIL: File /mnt/sshfs-share/welcome.txt not found on share"
  exit 1
fi

mount_opts=$(findmnt -no OPTIONS /mnt/sshfs-share 2>/dev/null)
if [[ "$mount_opts" != *"allow_other"* ]]; then
  echo "FAIL: Mount at /mnt/sshfs-share does not have 'allow_other' option active"
  exit 1
fi

echo "PASS: SSHFS mounted securely with user-space options"
exit 0
