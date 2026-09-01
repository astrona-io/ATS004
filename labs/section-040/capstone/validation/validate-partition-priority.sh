#!/usr/bin/env bash
# Confirms the extra disk's first partition's active swap priority is 10
# (preferred over the file's 5). Resolved via /dev/disk/by-id/virtio-<serial>
# rather than a hardcoded /dev/vdX letter -- see
# validate-partition-swap-active.sh for why.

set -u

BYID=/dev/disk/by-id/virtio-lab040-swap
if [[ ! -e "$BYID" ]]; then
  echo "FAIL: partition priority - $BYID not found"
  exit 1
fi

DISK=$(readlink -f "$BYID")
PART="${DISK}1"

if [[ ! -e "$PART" ]]; then
  echo "FAIL: partition priority - $PART not found"
  exit 1
fi

prio=""
while read -r name type p; do
  [[ -z "$name" ]] && continue
  if [[ "$(readlink -f "$name" 2>/dev/null)" == "$(readlink -f "$PART")" && "$type" == "partition" ]]; then
    prio="$p"
  fi
done < <(swapon --show=NAME,TYPE,PRIO --noheadings 2>/dev/null)

if [[ -z "$prio" ]]; then
  echo "FAIL: partition priority - $PART is not active as swap"
  exit 1
fi

if [[ "$prio" != "10" ]]; then
  echo "FAIL: partition priority - $PART priority is $prio, expected 10"
  exit 1
fi

echo "PASS: $PART swap priority is 10"
exit 0
