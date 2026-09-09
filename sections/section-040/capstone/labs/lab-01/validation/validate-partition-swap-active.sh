#!/usr/bin/env bash
# Confirms the extra disk's first partition is active as partition-type
# swap. Resolves the disk via its `serial` (set in config.yaml) through
# /dev/disk/by-id/virtio-<serial> rather than a hardcoded /dev/vdX letter,
# since astrona-cli's extraDisks aren't guaranteed to land on any
# particular letter.

set -u

BYID=/dev/disk/by-id/virtio-lab040-swap
if [[ ! -e "$BYID" ]]; then
  echo "FAIL: partition swap active - $BYID not found"
  exit 1
fi

DISK=$(readlink -f "$BYID")
PART="${DISK}1"

if [[ ! -e "$PART" ]]; then
  echo "FAIL: partition swap active - $PART not found"
  exit 1
fi

match="no"
while read -r name type; do
  [[ -z "$name" ]] && continue
  if [[ "$(readlink -f "$name" 2>/dev/null)" == "$(readlink -f "$PART")" && "$type" == "partition" ]]; then
    match="yes"
  fi
done < <(swapon --show=NAME,TYPE --noheadings 2>/dev/null)

if [[ "$match" != "yes" ]]; then
  echo "FAIL: partition swap active - $PART is not active as partition-type swap"
  exit 1
fi

echo "PASS: $PART is active as partition-type swap"
exit 0
