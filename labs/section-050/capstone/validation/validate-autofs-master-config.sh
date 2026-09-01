#!/usr/bin/env bash
# Confirms an autofs master map references /mnt/auto and an indirect map
# file whose entry points at data-001:/exports/shared.
set -u

master_line=""
for f in /etc/auto.master /etc/auto.master.d/*.autofs; do
  [[ -f "$f" ]] || continue
  line="$(grep -E '^[[:space:]]*/mnt/auto[[:space:]]' "$f" 2>/dev/null | head -1)"
  if [[ -n "$line" ]]; then
    master_line="$line"
    break
  fi
done

if [[ -z "$master_line" ]]; then
  echo "FAIL: autofs master config - no master map line for /mnt/auto found in /etc/auto.master or /etc/auto.master.d/*.autofs"
  exit 1
fi

map_file="$(awk '{print $2}' <<< "$master_line")"
if [[ ! -f "$map_file" ]]; then
  echo "FAIL: autofs master config - master map references indirect map '$map_file' which does not exist"
  exit 1
fi

if ! grep -Eq 'data-001:/exports/shared' "$map_file"; then
  echo "FAIL: autofs master config - indirect map $map_file has no entry for data-001:/exports/shared"
  exit 1
fi

if ! grep -Eq '^[[:space:]]*shared[[:space:]]' "$map_file"; then
  echo "FAIL: autofs master config - indirect map $map_file has no 'shared' key (needed for path /mnt/auto/shared)"
  exit 1
fi

echo "PASS: master map -> $map_file -> shared key -> data-001:/exports/shared"
exit 0
