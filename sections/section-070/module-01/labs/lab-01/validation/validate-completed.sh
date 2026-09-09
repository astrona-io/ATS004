#!/usr/bin/env bash
set -u

if [ ! -f "/opt/course/audit/slow_device.txt" ]; then
  echo "FAIL: /opt/course/audit/slow_device.txt does not exist"
  exit 1
fi

DISK2_DEV=$(readlink -f /dev/disk/by-id/virtio-lab071-disk2)
DISK2_NAME=$(basename "$DISK2_DEV")

student_guess=$(cat /opt/course/audit/slow_device.txt | xargs)

if [ "$student_guess" != "$DISK2_NAME" ]; then
  echo "FAIL: /opt/course/audit/slow_device.txt contains '$student_guess', expected '$DISK2_NAME'"
  exit 1
fi

echo "PASS: Saturated device correctly identified and logged"
exit 0
