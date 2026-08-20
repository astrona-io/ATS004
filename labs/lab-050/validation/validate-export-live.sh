#!/usr/bin/env bash
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
