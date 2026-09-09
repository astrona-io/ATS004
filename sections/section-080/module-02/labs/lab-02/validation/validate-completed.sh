#!/usr/bin/env bash
set -u

usage_kb=$(sudo du -sk /quota2/carol 2>/dev/null | awk '{print $1}')
if [ -z "$usage_kb" ]; then
  echo "FAIL: could not read /quota2/carol usage"
  exit 1
fi
if [ "$usage_kb" -gt 26000 ]; then
  echo "FAIL: carol's usage in /quota2/carol is ${usage_kb}K, exceeds her 25M hard limit - the write was not cut off"
  exit 1
fi

if [ ! -f /root/grace-evidence.txt ]; then
  echo "FAIL: /root/grace-evidence.txt not found - grace-period state was never captured"
  exit 1
fi
if ! grep -qE '^carol\b.*\*' /root/grace-evidence.txt; then
  echo "FAIL: /root/grace-evidence.txt does not show carol marked over her soft limit"
  cat /root/grace-evidence.txt
  exit 1
fi

echo "PASS: hard limit enforced, grace-period evidence captured"
exit 0
