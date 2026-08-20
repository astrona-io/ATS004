#!/usr/bin/env bash
# Checks /opt/course/audit/io-report.txt exists, is non-empty, and has all
# five expected keys present as "key: value" lines.

set -u

REPORT=/opt/course/audit/io-report.txt

if [[ ! -s "$REPORT" ]]; then
  echo "FAIL: io-report exists - $REPORT missing or empty"
  exit 1
fi

missing=()
for key in device pid process direction mountpoint; do
  if ! grep -Eiq "^[[:space:]]*${key}[[:space:]]*:[[:space:]]*\S" "$REPORT"; then
    missing+=("$key")
  fi
done

if [[ ${#missing[@]} -eq 0 ]]; then
  echo "PASS: io-report exists with all expected keys"
  exit 0
else
  echo "FAIL: io-report exists - missing/empty keys: ${missing[*]}"
  exit 1
fi
