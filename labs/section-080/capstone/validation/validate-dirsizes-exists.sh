#!/usr/bin/env bash
# Checks that /opt/course/audit/dirsizes.txt exists and is non-empty.

set -u

f=/opt/course/audit/dirsizes.txt

if [[ ! -f "$f" ]]; then
  echo "FAIL: dirsizes report - $f does not exist"
  exit 1
fi

if [[ ! -s "$f" ]]; then
  echo "FAIL: dirsizes report - $f is empty"
  exit 1
fi

echo "PASS: dirsizes report exists and is non-empty ($f)"
exit 0
