#!/usr/bin/env bash
# Checks io-report.txt's "direction" line correctly identifies the load as
# write-bound (the bootstrap load is a dd write loop).

set -u

REPORT=/opt/course/audit/io-report.txt

[[ -f "$REPORT" ]] || { echo "FAIL: io-report direction - $REPORT not found"; exit 1; }

value=$(grep -Ei '^[[:space:]]*direction[[:space:]]*:' "$REPORT" | head -1 | cut -d: -f2- | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

if [[ "$value" == "write" ]]; then
  echo "PASS: io-report direction correctly identified as write"
  exit 0
else
  echo "FAIL: io-report direction - expected 'write', got '$value'"
  exit 1
fi
