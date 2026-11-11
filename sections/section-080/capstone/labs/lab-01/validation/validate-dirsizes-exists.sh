#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
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
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
