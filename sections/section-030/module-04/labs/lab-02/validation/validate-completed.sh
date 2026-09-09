#!/usr/bin/env bash
set -u

detail=$(sudo mdadm --detail /dev/md0 2>/dev/null)
if ! echo "$detail" | grep -qE 'Raid Devices\s*:\s*4'; then
  echo "FAIL: array was not grown to 4 raid devices"
  echo "$detail"
  exit 1
fi

if ! grep -q '\[4/4\]' /proc/mdstat 2>/dev/null; then
  echo "FAIL: /proc/mdstat does not show a healthy [4/4] array"
  cat /proc/mdstat
  exit 1
fi

size_kb=$(df --output=size /mnt/raid-grow 2>/dev/null | tail -1 | tr -d ' ')
if [ -z "$size_kb" ] || [ "$size_kb" -lt 2600000 ]; then
  echo "FAIL: /mnt/raid-grow filesystem does not appear to have grown (size: ${size_kb}K, expected > 2.6GB after growing to 4 disks)"
  exit 1
fi

if ! grep -q "growth test dataset" /mnt/raid-grow/data.txt 2>/dev/null; then
  echo "FAIL: data.txt missing or corrupted after the grow"
  exit 1
fi

if ! grep -q "^MAILADDR" /etc/mdadm/mdadm.conf 2>/dev/null; then
  echo "FAIL: /etc/mdadm/mdadm.conf has no MAILADDR line - failure notification not configured"
  exit 1
fi

echo "PASS: array grown to 4 disks, filesystem extended, data intact, monitoring configured"
exit 0
