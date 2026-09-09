#!/usr/bin/env bash
set -u

if [ ! -f "/opt/course/audit/fd_count.txt" ]; then
  echo "FAIL: /opt/course/audit/fd_count.txt does not exist"
  exit 1
fi

if [ ! -f "/opt/course/audit/file_max.txt" ]; then
  echo "FAIL: /opt/course/audit/file_max.txt does not exist"
  exit 1
fi

sys_limit=$(cat /proc/sys/fs/file-max)
audit_limit=$(cat /opt/course/audit/file_max.txt | xargs)

if [ "$sys_limit" != "$audit_limit" ]; then
  echo "FAIL: /opt/course/audit/file_max.txt is '$audit_limit', expected system limit '$sys_limit'"
  exit 1
fi

fd_count=$(cat /opt/course/audit/fd_count.txt | xargs)
if ! [[ "$fd_count" =~ ^[0-9]+$ ]]; then
  echo "FAIL: /opt/course/audit/fd_count.txt does not contain a valid integer (value: '$fd_count')"
  exit 1
fi

actual_count=$(sudo ls -1 /proc/$(pidof systemd-journald)/fd | wc -l)
diff_count=$(( actual_count - fd_count ))
if [ ${diff_count#-} -gt 15 ]; then
  echo "FAIL: fd_count is '$fd_count' but live systemd-journald fd count is '$actual_count'"
  exit 1
fi

echo "PASS: Process and system limits audited successfully"
exit 0
