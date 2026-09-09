#!/usr/bin/env bash
# Confirms an ext4 filesystem is mounted at /mnt/backup-black and the completed file exists

set -u

source=$(findmnt -no SOURCE /mnt/backup-black 2>/dev/null)
if [[ -z "$source" ]]; then
  echo "FAIL: scratch disk formatted/mounted - nothing is mounted at /mnt/backup-black"
  exit 1
fi

fstype=$(findmnt -no FSTYPE /mnt/backup-black 2>/dev/null)
if [[ "$fstype" != "ext4" ]]; then
  echo "FAIL: scratch disk formatted/mounted - $source is mounted at /mnt/backup-black but is '$fstype', expected ext4"
  exit 1
fi

if [[ ! -f "/mnt/backup-black/completed" ]]; then
  echo "FAIL: scratch disk formatted/mounted - missing required marker file /mnt/backup-black/completed"
  exit 1
fi

echo "PASS: $source is ext4 and mounted at /mnt/backup-black with completed file."
exit 0
