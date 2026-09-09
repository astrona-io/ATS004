#!/usr/bin/env bash
set -u

size_raw=$(sudo lvs --noheadings --units m --nosuffix -o lv_size vg_resize/lv_data 2>/dev/null | tr -d ' ')
if [ -z "$size_raw" ]; then
  echo "FAIL: logical volume vg_resize/lv_data not found"
  exit 1
fi

size_int=${size_raw%.*}
if [ "$size_int" -lt 330 ] || [ "$size_int" -gt 370 ]; then
  echo "FAIL: lv_data size is ${size_raw}M, expected roughly 350M (grow to 500M then shrink to 350M)"
  exit 1
fi

fstype=$(findmnt -no FSTYPE /mnt/resize-data 2>/dev/null)
if [ "$fstype" != "ext4" ]; then
  echo "FAIL: /mnt/resize-data is not mounted as ext4 (got '$fstype')"
  exit 1
fi

if ! grep -q "resize marker" /mnt/resize-data/marker.txt 2>/dev/null; then
  echo "FAIL: marker.txt missing or corrupted - the shrink may have destroyed live data"
  exit 1
fi

echo "PASS: lv_data grown then correctly shrunk to ~350M, filesystem healthy, data intact"
exit 0
