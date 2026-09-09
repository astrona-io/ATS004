#!/usr/bin/env bash
set -u

if [ ! -f "/swapfile" ]; then
  echo "FAIL: /swapfile does not exist"
  exit 1
fi

perms=$(stat -c "%a" /swapfile)
if [ "$perms" != "600" ]; then
  echo "FAIL: /swapfile permissions are '$perms', expected '600'"
  exit 1
fi

if ! swapon --show | grep -q "/swapfile"; then
  echo "FAIL: /swapfile is not active as swap space"
  exit 1
fi

if ! grep -q "/swapfile" /etc/fstab; then
  echo "FAIL: /swapfile entry not found in /etc/fstab"
  exit 1
fi

echo "PASS: Swap file created, secured, and activated successfully"
exit 0
