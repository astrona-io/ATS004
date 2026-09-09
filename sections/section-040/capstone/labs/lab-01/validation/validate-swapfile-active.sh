#!/usr/bin/env bash
# Confirms a ~2G file-type swap area is active.

set -u

line="$(swapon --show=NAME,TYPE,SIZE --noheadings 2>/dev/null | awk '$2=="file"{print;exit}')"
if [[ -z "$line" ]]; then
  echo "FAIL: swapfile active - no active swap area of type 'file' found in 'swapon --show'"
  exit 1
fi

name="$(awk '{print $1}' <<<"$line")"
size_bytes="$(swapon --show=NAME,SIZE -b --noheadings 2>/dev/null | awk -v n="$name" '$1==n{print $2}')"

# Accept 2G +/- 5%
min=$((2*1024*1024*1024*95/100))
max=$((2*1024*1024*1024*105/100))
if [[ -z "$size_bytes" ]] || (( size_bytes < min || size_bytes > max )); then
  echo "FAIL: swapfile active - $name is active but size (${size_bytes:-unknown} bytes) is not ~2G"
  exit 1
fi

echo "PASS: swapfile $name is active with size ~2G"
exit 0
