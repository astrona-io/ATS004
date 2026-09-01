#!/usr/bin/env bash
# Confirms the active swap file's priority is 5 (fallback, lower than the partition).

set -u

prio="$(swapon --show=TYPE,PRIO --noheadings 2>/dev/null | awk '$1=="file"{print $2;exit}')"
if [[ -z "$prio" ]]; then
  echo "FAIL: swapfile priority - no active file-type swap area found"
  exit 1
fi

if [[ "$prio" != "5" ]]; then
  echo "FAIL: swapfile priority - active file swap priority is $prio, expected 5"
  exit 1
fi

echo "PASS: swap file priority is 5"
exit 0
