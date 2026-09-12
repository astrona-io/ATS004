#!/usr/bin/env bash
set -u

if ! sudo lvs vg_pool/lv_wide >/dev/null 2>&1; then
  echo "FAIL: Logical Volume 'vg_pool/lv_wide' not found (step 3: 'sudo lvcreate -L 1500M -n lv_wide vg_pool')"
  exit 1
fi

size_raw=$(sudo lvs --noheadings --units m --nosuffix -o lv_size vg_pool/lv_wide 2>/dev/null | tr -d ' ')
size_int=${size_raw%.*}
if [ -z "$size_int" ] || [ "$size_int" -lt 1400 ] || [ "$size_int" -gt 1600 ]; then
  echo "FAIL: lv_wide size is '${size_raw}M', expected roughly 1500M (step 3 asked for -L 1500M)"
  exit 1
fi

echo "PASS: lv_wide exists at roughly 1500M"
exit 0
