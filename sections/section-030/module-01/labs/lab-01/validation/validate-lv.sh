#!/usr/bin/env bash
set -u

if ! sudo lvs vg_data/lv_storage >/dev/null 2>&1; then
  echo "FAIL: Logical Volume 'vg_data/lv_storage' not found (step 4: run 'sudo lvcreate -L 500M -n lv_storage vg_data')"
  exit 1
fi

size_raw=$(sudo lvs --noheadings --units m --nosuffix -o lv_size vg_data/lv_storage 2>/dev/null | tr -d ' ')
size_int=${size_raw%.*}
if [ -z "$size_int" ] || [ "$size_int" -lt 450 ] || [ "$size_int" -gt 550 ]; then
  echo "FAIL: lv_storage size is '${size_raw}M', expected roughly 500M (step 4 asked for -L 500M)"
  exit 1
fi

echo "PASS: Logical Volume lv_storage exists at roughly 500M"
exit 0
