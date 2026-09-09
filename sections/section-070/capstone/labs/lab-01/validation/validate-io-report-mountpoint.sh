#!/usr/bin/env bash
# Checks io-report.txt's "mountpoint" line names the filesystem the busy
# device actually backs, /mnt/data-ingest.

set -u

REPORT=/opt/course/audit/io-report.txt

[[ -f "$REPORT" ]] || { echo "FAIL: io-report mountpoint - $REPORT not found"; exit 1; }

value=$(grep -Ei '^[[:space:]]*mountpoint[[:space:]]*:' "$REPORT" | head -1 | cut -d: -f2-)

if echo "$value" | grep -q '/mnt/data-ingest'; then
  echo "PASS: io-report mountpoint names /mnt/data-ingest"
  exit 0
else
  echo "FAIL: io-report mountpoint - expected '/mnt/data-ingest', got '$value'"
  exit 1
fi
