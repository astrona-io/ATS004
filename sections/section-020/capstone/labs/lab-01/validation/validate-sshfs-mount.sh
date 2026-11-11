#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Checks that /app-srv1/data-export is mounted via SSHFS, read-write,
# with allow_other set.

set -u

line=$(mount | grep -F '/app-srv1/data-export' | grep fuse.sshfs || true)

if [[ -z "$line" ]]; then
  echo "FAIL: sshfs mount - /app-srv1/data-export is not mounted as fuse.sshfs"
  exit 1
fi

if ! echo "$line" | grep -Eq '\(.*\brw\b'; then
  echo "FAIL: sshfs mount - not mounted read-write: $line"
  exit 1
fi

if ! echo "$line" | grep -q 'allow_other'; then
  echo "FAIL: sshfs mount - allow_other not set: $line"
  exit 1
fi

echo "PASS: /app-srv1/data-export mounted fuse.sshfs, rw, allow_other ($line)"
exit 0
ASTRONA_STUDENT_SCRIPT
