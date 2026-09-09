#!/usr/bin/env bash
# Checks io-report.txt's "device" line refers to the actual device mounted
# at /mnt/data-ingest. Resolved live rather than hardcoded -- astrona-cli's
# extraDisks aren't guaranteed to land on any particular /dev/vdX letter,
# so this never assumes "vdb" is correct.

set -u

REPORT=/opt/course/audit/io-report.txt

[[ -f "$REPORT" ]] || { echo "FAIL: io-report device - $REPORT not found"; exit 1; }

actual_source=$(findmnt -no SOURCE /mnt/data-ingest 2>/dev/null)
if [[ -z "$actual_source" ]]; then
  echo "FAIL: io-report device - nothing is mounted at /mnt/data-ingest to compare against"
  exit 1
fi
actual_resolved=$(readlink -f "$actual_source" 2>/dev/null)

value=$(grep -Ei '^[[:space:]]*device[[:space:]]*:' "$REPORT" | head -1 | cut -d: -f2- | tr -d '[:space:]')
if [[ -z "$value" ]]; then
  echo "FAIL: io-report device - no 'device:' line found in $REPORT"
  exit 1
fi

# Accept a bare letter ("vdb"), a full path ("/dev/vdb"), or a by-id path --
# resolve whatever the student wrote to a real device path and compare that
# against the actual mount source by resolved path (and device number as a
# fallback, in case of symlink weirdness).
candidate="$value"
[[ "$candidate" == /dev/* || "$candidate" == /dev/disk/* ]] || candidate="/dev/$candidate"
candidate_resolved=$(readlink -f "$candidate" 2>/dev/null)

if [[ -n "$candidate_resolved" && "$candidate_resolved" == "$actual_resolved" ]]; then
  echo "PASS: io-report device '$value' resolves to the disk mounted at /mnt/data-ingest ($actual_resolved)"
  exit 0
fi

# Fallback: compare underlying device numbers in case path resolution
# differs but they're still the same block device.
actual_devno=$(stat -c '%t:%T' "$actual_resolved" 2>/dev/null)
candidate_devno=$(stat -c '%t:%T' "$candidate_resolved" 2>/dev/null)
if [[ -n "$actual_devno" && "$actual_devno" == "$candidate_devno" ]]; then
  echo "PASS: io-report device '$value' matches the disk mounted at /mnt/data-ingest by device number"
  exit 0
fi

echo "FAIL: io-report device - '$value' does not resolve to $actual_resolved, the disk actually mounted at /mnt/data-ingest"
exit 1
