#!/usr/bin/env bash
# Checks that /nfs/terminal/share is mounted from terminal's NFS export,
# type nfs, read-only.

set -u

line=$(mount | grep -F '/nfs/terminal/share' || true)

if [[ -z "$line" ]]; then
  echo "FAIL: nfs mount - /nfs/terminal/share is not mounted"
  exit 1
fi

if ! echo "$line" | grep -Eq 'type nfs[0-9]?\b'; then
  echo "FAIL: nfs mount - not type nfs: $line"
  exit 1
fi

if ! echo "$line" | grep -Eq '\(.*\bro\b'; then
  echo "FAIL: nfs mount - not read-only: $line"
  exit 1
fi

if ! echo "$line" | grep -Fq 'terminal:/nfs/share'; then
  echo "FAIL: nfs mount - source is not terminal:/nfs/share: $line"
  exit 1
fi

echo "PASS: /nfs/terminal/share mounted from terminal:/nfs/share, nfs, ro ($line)"
exit 0
