#!/usr/bin/env bash
set -u

if [ ! -f /etc/lab034-raid ]; then
  echo "FAIL: /etc/lab034-raid not found"
  exit 1
fi
# shellcheck source=/dev/null
source /etc/lab034-raid

detail=$(sudo mdadm --detail /dev/md0 2>/dev/null)
if [ -z "$detail" ]; then
  echo "FAIL: /dev/md0 does not exist or mdadm --detail failed"
  exit 1
fi

state=$(echo "$detail" | awk -F: '/^ *State/{gsub(/^ +| +$/,"",$2); print $2; exit}')
if [ "$state" != "clean" ]; then
  echo "FAIL: array State is '$state', expected 'clean' (not degraded/resyncing/recovering)"
  exit 1
fi

active=$(echo "$detail" | awk -F: '/Active Devices/{gsub(/^ +| +$/,"",$2); print $2; exit}')
if [ "$active" != "3" ]; then
  echo "FAIL: Active Devices is '$active', expected 3"
  exit 1
fi

failed=$(echo "$detail" | awk -F: '/Failed Devices/{gsub(/^ +| +$/,"",$2); print $2; exit}')
if [ "$failed" != "0" ]; then
  echo "FAIL: Failed Devices is '$failed', expected 0"
  exit 1
fi

mdstat=$(cat /proc/mdstat)
if ! echo "$mdstat" | grep -q '\[3/3\]'; then
  echo "FAIL: /proc/mdstat does not show [3/3]"
  exit 1
fi
if echo "$mdstat" | grep -qE 'md0.*\(F\)'; then
  echo "FAIL: /proc/mdstat still shows a failed (F) member on md0"
  exit 1
fi

spare_name=$(basename "$spare" 2>/dev/null || true)
if [ -n "$spare_name" ] && ! echo "$detail" | grep -q "$spare_name"; then
  echo "FAIL: spare device $spare does not appear as an active member of /dev/md0"
  exit 1
fi

if ! grep -q "critical dataset row 1" /mnt/raid/data.txt 2>/dev/null; then
  echo "FAIL: /mnt/raid/data.txt is missing or its content changed"
  exit 1
fi

echo "PASS: RAID5 array recovered -- clean, 3 active devices, spare integrated, data intact"
exit 0
