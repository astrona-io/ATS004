#!/usr/bin/env bash
# Confirms the idle-unmount timeout is 300s, either on the master map's
# /mnt/auto line or globally in /etc/autofs.conf.
set -u

for f in /etc/auto.master /etc/auto.master.d/*.autofs; do
  [[ -f "$f" ]] || continue
  if grep -E '^[[:space:]]*/mnt/auto[[:space:]]' "$f" 2>/dev/null | grep -Eq 'timeout=300\b'; then
    echo "PASS: /mnt/auto master map line sets --timeout=300"
    exit 0
  fi
done

if [[ -f /etc/autofs.conf ]] && grep -Eq '^[[:space:]]*TIMEOUT[[:space:]]*=[[:space:]]*300\b' /etc/autofs.conf; then
  echo "PASS: /etc/autofs.conf sets global TIMEOUT=300"
  exit 0
fi

echo "FAIL: autofs timeout - no 300s timeout found on the /mnt/auto master map line or in /etc/autofs.conf's TIMEOUT"
exit 1
