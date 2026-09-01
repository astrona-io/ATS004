#!/usr/bin/env bash
# Checks that /opt/course/audit/dirsizes.txt contains no /proc, /sys, /dev,
# or /run entries — those are pseudo-filesystems, not real disk usage.

set -u

f=/opt/course/audit/dirsizes.txt

if [[ ! -f "$f" ]]; then
  echo "FAIL: pseudo-fs exclusion - $f does not exist"
  exit 1
fi

hits=$(grep -Ei '(^|[[:space:]])/(proc|sys|dev|run)([[:space:]]|$)' "$f" || true)

if [[ -n "$hits" ]]; then
  echo "FAIL: pseudo-fs exclusion - report contains pseudo-filesystem entries: $hits"
  exit 1
fi

echo "PASS: dirsizes report excludes /proc, /sys, /dev, /run"
exit 0
