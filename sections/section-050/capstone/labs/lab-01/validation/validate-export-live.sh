#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms /exports/shared is actively exported by data-001's NFS server.
set -u

if ! command -v exportfs >/dev/null 2>&1; then
  echo "FAIL: export live - exportfs not found on data-001"
  exit 1
fi

if sudo exportfs -v 2>/dev/null | grep -q '/exports/shared'; then
  echo "PASS: /exports/shared is actively exported"
  exit 0
else
  echo "FAIL: export live - /exports/shared not found in 'exportfs -v' output"
  exit 1
fi
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
