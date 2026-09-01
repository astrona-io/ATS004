#!/usr/bin/env bash
# Confirms vol2/p1 exists, is ~50M (rounded to extent size), and is ext4.

set -u

if ! sudo lvs vol2/p1 >/dev/null 2>&1; then
  echo "FAIL: lv p1 - logical volume 'vol2/p1' does not exist"
  exit 1
fi

size_mib=$(sudo lvs --noheadings --units m --nosuffix -o lv_size vol2/p1 2>/dev/null | tr -d '[:space:]')
size_int=${size_mib%.*}

if [[ -z "$size_int" ]] || (( size_int < 48 || size_int > 56 )); then
  echo "FAIL: lv p1 - expected size close to 50M, got '${size_mib}m'"
  exit 1
fi

lv_path="/dev/vol2/p1"
fstype=$(sudo blkid -o value -s TYPE "$lv_path" 2>/dev/null)

if [[ "$fstype" != "ext4" ]]; then
  echo "FAIL: lv p1 - expected ext4 on $lv_path, got '${fstype:-none}'"
  exit 1
fi

echo "PASS: vol2/p1 is a ${size_mib}m ext4 logical volume"
exit 0
