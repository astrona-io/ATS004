#!/usr/bin/env bash
set -u

if ! grep -q "^\s*/mnt/net\s\+/etc/auto.net" /etc/auto.master; then
  echo "FAIL: Indirect map '/mnt/net /etc/auto.net' not found in /etc/auto.master"
  exit 1
fi

if ! grep -E "^\s*/mnt/net\s\+/etc/auto.net" /etc/auto.master | grep -q "timeout=120"; then
  echo "FAIL: Timeout for /mnt/net is not set to 120"
  exit 1
fi

if ! grep -E "^\s*\*\s+.*127.0.0.1:/var/nfs/exports/\&" /etc/auto.net >/dev/null 2>&1; then
  echo "FAIL: Wildcard or substitution mapping in /etc/auto.net is missing or incorrect"
  exit 1
fi

if [ ! -f "/mnt/net/project-alpha/alpha.txt" ]; then
  echo "FAIL: On-demand mount of project-alpha failed"
  exit 1
fi

mount_type=$(findmnt -no FSTYPE /mnt/net/project-alpha 2>/dev/null)
if [[ "$mount_type" != "nfs" ]] && [[ "$mount_type" != "nfs4" ]]; then
  echo "FAIL: Mount at /mnt/net/project-alpha is type '$mount_type', expected nfs"
  exit 1
fi

echo "PASS: autofs wildcard indirect map configured and verified successfully"
exit 0
