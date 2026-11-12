#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Checks io-report.txt's "process" line names the actual load-generating
# process, data-ingest-job.

set -u

REPORT=/opt/course/audit/io-report.txt

[[ -f "$REPORT" ]] || { echo "FAIL: io-report process - $REPORT not found"; exit 1; }

value=$(grep -Ei '^[[:space:]]*process[[:space:]]*:' "$REPORT" | head -1 | cut -d: -f2-)

pid=$(awk -F: '/^[[:space:]]*pid[[:space:]]*:/ {gsub(/[[:space:]]/, "", $2); print $2; exit}' "$REPORT")
actual=$(systemctl show data-ingest-job.service -p MainPID --value)
if [[ ! "$pid" =~ ^[0-9]+$ || "$pid" -le 1 || "$pid" != "$actual" ]] || ! sudo test -r "/proc/$pid/io"; then
  echo "FAIL: io-report process - PID must identify the running data-ingest-job service"
  exit 1
fi

if echo "$value" | grep -qi 'data-ingest'; then
  echo "PASS: io-report process names data-ingest-job"
  exit 0
else
  echo "FAIL: io-report process - expected a name containing 'data-ingest', got '$value'"
  exit 1
fi
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
