#!/usr/bin/env bash
# Checks that the /mnt entry in dirsizes.txt (if present) is small — proving
# du -x kept the scan from crossing into the ~1G bigshare mount underneath
# it. If /mnt doesn't appear as its own top-level line, skip gracefully.

set -u

f=/opt/course/audit/dirsizes.txt

if [[ ! -f "$f" ]]; then
  echo "FAIL: mount boundary - $f does not exist"
  exit 1
fi

line=$(grep -E '(^|[[:space:]])/mnt[[:space:]]*$' "$f" || true)

if [[ -z "$line" ]]; then
  echo "PASS: no standalone /mnt line in report (nothing to check) - skipped"
  exit 0
fi

size_tok=$(awk '{print $1}' <<<"$line")

bytes=$(awk -v tok="$size_tok" '
BEGIN {
  if (tok ~ /^[0-9.]+$/) { printf "%d\n", tok + 0; exit }
  unit = substr(tok, length(tok), 1)
  num = substr(tok, 1, length(tok) - 1) + 0
  if (unit == "K") mult = 1024
  else if (unit == "M") mult = 1024^2
  else if (unit == "G") mult = 1024^3
  else if (unit == "T") mult = 1024^4
  else { printf "%d\n", tok + 0; exit }
  printf "%d\n", num * mult
}')

limit=$((100 * 1024 * 1024))

if [[ "$bytes" -ge "$limit" ]]; then
  echo "FAIL: mount boundary - /mnt reported as $size_tok (>=100M), du likely crossed into the bigshare mount without -x"
  exit 1
fi

echo "PASS: /mnt entry ($size_tok) is small, mount boundary respected"
exit 0
