#!/usr/bin/env bash
# Confirms the active swap file is persisted in /etc/fstab with type swap.

set -u

name="$(swapon --show=NAME,TYPE --noheadings 2>/dev/null | awk '$2=="file"{print $1;exit}')"
if [[ -z "$name" ]]; then
  echo "FAIL: swapfile fstab - no active file-type swap area found"
  exit 1
fi

if ! grep -Eq "^[[:space:]]*${name//\//\\/}[[:space:]]+none[[:space:]]+swap([[:space:]]|\$)" /etc/fstab; then
  echo "FAIL: swapfile fstab - no '/etc/fstab' entry found for $name with type 'swap'"
  exit 1
fi

echo "PASS: $name is persisted in /etc/fstab as swap"
exit 0
