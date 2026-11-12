#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
set -u

if [ ! -f "/opt/course/audit/heavy_dirs.txt" ]; then
  echo "FAIL: /opt/course/audit/heavy_dirs.txt does not exist"
  exit 1
fi

student_val=$(cat /opt/course/audit/heavy_dirs.txt | xargs)

if [ "$student_val" != "/var/log/heavy_local_log" ]; then
  echo "FAIL: /opt/course/audit/heavy_dirs.txt is '$student_val', expected '/var/log/heavy_local_log'"
  exit 1
fi

echo "PASS: Local directory capacity correctly audited"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
