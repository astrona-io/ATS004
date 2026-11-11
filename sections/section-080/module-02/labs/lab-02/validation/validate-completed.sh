#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
set -u

# Flush delayed allocation before reading the kernel quota counters.
sync

usage_kb=$(sudo du -sk /quota2/carol 2>/dev/null | awk '{print $1}')
if [ -z "$usage_kb" ]; then
  echo "FAIL: could not read /quota2/carol usage"
  exit 1
fi
if [ "$usage_kb" -gt 26000 ]; then
  echo "FAIL: carol's usage in /quota2/carol is ${usage_kb}K, exceeds her 25M hard limit - the write was not cut off"
  exit 1
fi

if ! sudo repquota /quota2 | awk '$1 == "carol" && $2 ~ /^\+/ && $3 > 20480 && $3 <= 25600 && $4 == 20480 && $5 == 25600 {ok=1} END {exit !ok}'; then
  echo "FAIL: carol must be over her 20M soft limit and within her 25M hard limit"
  exit 1
fi

if [ ! -f /root/grace-evidence.txt ]; then
  echo "FAIL: /root/grace-evidence.txt not found - grace-period state was never captured"
  exit 1
fi
if ! grep -qE '^carol[[:space:]]+\+' /root/grace-evidence.txt; then
  echo "FAIL: /root/grace-evidence.txt does not show carol marked over her soft limit"
  cat /root/grace-evidence.txt
  exit 1
fi

echo "PASS: hard limit enforced, grace-period evidence captured"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
