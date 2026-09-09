#!/usr/bin/env bash
set -u

if [ ! -f "/opt/course/audit/culprit.txt" ]; then
  echo "FAIL: /opt/course/audit/culprit.txt does not exist"
  exit 1
fi

actual_pid=$(pgrep -f "rogue_writer.py" | head -n 1)

if [ -z "$actual_pid" ]; then
  echo "FAIL: Rogue writer process is not running"
  exit 1
fi

student_pid=$(head -n 1 /opt/course/audit/culprit.txt | xargs)
student_path=$(tail -n 1 /opt/course/audit/culprit.txt | xargs)

if [ "$student_pid" != "$actual_pid" ]; then
  echo "FAIL: First line of culprit.txt is '$student_pid', expected PID '$actual_pid'"
  exit 1
fi

if [ "$student_path" != "/var/log/rogue_activity.log" ]; then
  echo "FAIL: Second line of culprit.txt is '$student_path', expected '/var/log/rogue_activity.log'"
  exit 1
fi

echo "PASS: Rogue process PID and locked target log file correctly identified"
exit 0
