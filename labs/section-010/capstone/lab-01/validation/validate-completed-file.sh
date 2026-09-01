#!/usr/bin/env bash
# Confirms /mnt/backup-black/completed exists as an empty regular file.

set -u

f=/mnt/backup-black/completed

if [[ ! -e "$f" ]]; then
  echo "FAIL: completed file - $f does not exist"
  exit 1
fi

if [[ ! -f "$f" ]]; then
  echo "FAIL: completed file - $f exists but is not a regular file"
  exit 1
fi

size=$(stat -c%s "$f" 2>/dev/null || echo -1)
if [[ "$size" -ne 0 ]]; then
  echo "FAIL: completed file - $f is not empty (size=$size)"
  exit 1
fi

echo "PASS: $f exists and is an empty regular file"
exit 0
