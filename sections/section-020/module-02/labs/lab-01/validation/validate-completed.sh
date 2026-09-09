#!/usr/bin/env bash
set -u

if ! grep -q "/var/nfs/public" /etc/exports; then
  echo "FAIL: /var/nfs/public not found in /etc/exports"
  exit 1
fi

mount_type=$(findmnt -no FSTYPE /mnt/nfs-share 2>/dev/null)
if [[ "$mount_type" != "nfs" ]] && [[ "$mount_type" != "nfs4" ]]; then
  echo "FAIL: Expected nfs or nfs4 mount at /mnt/nfs-share, found '$mount_type'"
  exit 1
fi

mount_opts=$(findmnt -no OPTIONS /mnt/nfs-share 2>/dev/null)
if [[ "$mount_opts" != *"ro"* ]]; then
  echo "FAIL: NFS mount at /mnt/nfs-share is not mounted read-only"
  exit 1
fi

if touch /mnt/nfs-share/probe-file >/dev/null 2>&1; then
  echo "FAIL: Writing is allowed on /mnt/nfs-share, it must be read-only"
  rm -f /mnt/nfs-share/probe-file
  exit 1
fi

echo "PASS: NFS read-only share configured, exported, and mounted successfully"
exit 0
