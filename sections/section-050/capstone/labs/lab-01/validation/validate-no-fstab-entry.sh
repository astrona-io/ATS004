#!/usr/bin/env bash
# Confirms /etc/fstab has no permanent entry for the shared export --
# autofs must be used on demand instead.
set -u

if grep -Eq '(exports/shared|data-001)' /etc/fstab; then
  echo "FAIL: no fstab entry - /etc/fstab references the shared export; a permanent mount was used instead of autofs"
  exit 1
fi

echo "PASS: /etc/fstab has no entry for the shared export"
exit 0
