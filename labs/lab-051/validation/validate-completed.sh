#!/usr/bin/env bash
set -u

if ! grep -q "^\s*/-\s\+/etc/auto.direct" /etc/auto.master; then
  echo "FAIL: Direct map entry '/- /etc/auto.direct' not found in /etc/auto.master"
  exit 1
fi

if ! grep -E "^\s*/-\s\+/etc/auto.direct" /etc/auto.master | grep -q "timeout=60"; then
  echo "FAIL: Direct map timeout is not configured to 60 seconds"
  exit 1
fi

if ! grep -q "^\s*/mnt/secure_archive\s\+-fstype=bind\s\+:/var/data/archive" /etc/auto.direct; then
  echo "FAIL: /mnt/secure_archive is not correctly mapped in /etc/auto.direct"
  exit 1
fi

if [ ! -f "/mnt/secure_archive/archive.txt" ]; then
  echo "FAIL: Cannot read files in /mnt/secure_archive. automount failed."
  exit 1
fi

mount_type=$(findmnt -no FSTYPE /mnt/secure_archive 2>/dev/null)
if [[ "$mount_type" != "autofs" ]] && [[ "$mount_type" != "ext4" ]] && [[ "$mount_type" != "bind" ]]; then
  echo "FAIL: Expected bind mount type at /mnt/secure_archive, found '$mount_type'"
  exit 1
fi

echo "PASS: autofs direct map and timeout configured and verified successfully"
exit 0
