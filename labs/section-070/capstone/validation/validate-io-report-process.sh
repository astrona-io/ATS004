#!/usr/bin/env bash
# Checks io-report.txt's "process" line names the actual load-generating
# process, data-ingest-job.

set -u

REPORT=/opt/course/audit/io-report.txt

[[ -f "$REPORT" ]] || { echo "FAIL: io-report process - $REPORT not found"; exit 1; }

value=$(grep -Ei '^[[:space:]]*process[[:space:]]*:' "$REPORT" | head -1 | cut -d: -f2-)

if echo "$value" | grep -qi 'data-ingest'; then
  echo "PASS: io-report process names data-ingest-job"
  exit 0
else
  echo "FAIL: io-report process - expected a name containing 'data-ingest', got '$value'"
  exit 1
fi
