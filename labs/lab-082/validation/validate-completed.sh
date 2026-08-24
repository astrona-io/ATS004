#!/usr/bin/env bash
set -u

if [ ! -f "/opt/course/audit/symlink_report.txt" ]; then
  echo "FAIL: /opt/course/audit/symlink_report.txt does not exist"
  exit 1
fi

expected_content=$(cat <<'EOF'
/usr/share/lab-links/link1
/usr/share/lab-links/link3
EOF
)

student_content=$(cat /opt/course/audit/symlink_report.txt | sort | xargs)
clean_expected=$(echo "$expected_content" | sort | xargs)

if [ "$student_content" != "$clean_expected" ]; then
  echo "FAIL: /opt/course/audit/symlink_report.txt content is incorrect"
  echo "Expected:"
  echo "$clean_expected"
  echo "Got:"
  echo "$student_content"
  exit 1
fi

echo "PASS: Symbolic links successfully located and targets resolved"
exit 0
