#!/usr/bin/env bash
# Checks that /nfs/share is exported read-only to 10.10.40.0/24.

set -u

out=$(sudo exportfs -v 2>/dev/null | grep -F '/nfs/share' || true)

if [[ -z "$out" ]]; then
  echo "FAIL: nfs export - /nfs/share is not exported"
  exit 1
fi

if ! echo "$out" | grep -q '10.10.40.0/24'; then
  echo "FAIL: nfs export - not restricted to 10.10.40.0/24: $out"
  exit 1
fi

if ! echo "$out" | grep -q 'ro,'; then
  echo "FAIL: nfs export - not read-only: $out"
  exit 1
fi

echo "PASS: /nfs/share exported ro to 10.10.40.0/24 ($out)"
exit 0
