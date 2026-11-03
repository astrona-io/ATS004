#!/usr/bin/env bash
set -u

fail() { echo "FAIL: $*"; exit 1; }

sudo lvs vg_data/lv_reports >/dev/null 2>&1 || fail "logical volume vg_data/lv_reports not found"

# --- The volume was grown by about 300M (500M + 300M) ---
size_raw=$(sudo lvs --noheadings --units m --nosuffix -o lv_size vg_data/lv_reports 2>/dev/null | tr -d ' ')
size_int=${size_raw%.*}
if [ -z "$size_int" ] || [ "$size_int" -lt 780 ] || [ "$size_int" -gt 840 ]; then
  fail "lv_reports is '${size_raw}M', expected about 800M (500M + 300M)"
fi

# --- The fstab line exists and names this volume ---
fstab_line=$(grep -vE '^[[:space:]]*#' /etc/fstab | awk '$2=="/mnt/reports"')
[ -n "$fstab_line" ] || fail "no /etc/fstab line for /mnt/reports"

source_field=$(echo "$fstab_line" | awk '{print $1}')
fs_uuid=$(sudo blkid -s UUID -o value /dev/vg_data/lv_reports 2>/dev/null)
case "$source_field" in
  "UUID=$fs_uuid"|/dev/mapper/vg_data-lv_reports|/dev/vg_data/lv_reports) ;;
  *) fail "fstab source is '$source_field', expected UUID=$fs_uuid or the volume's device path" ;;
esac
[ "$(echo "$fstab_line" | awk '{print $3}')" = "ext4" ] || fail "fstab type for /mnt/reports is not ext4"

# --- Prove the line works: drop the mount, let mount -a bring it back ---
sudo umount /mnt/reports 2>/dev/null
sudo mount -a >/dev/null 2>&1
fstype=$(findmnt -no FSTYPE /mnt/reports 2>/dev/null)
[ "$fstype" = "ext4" ] || fail "after 'mount -a', /mnt/reports is not mounted as ext4 (found '$fstype')"

# --- The filesystem itself was grown, not only the volume ---
fs_bytes=$(df -B1 --output=size /mnt/reports 2>/dev/null | tail -1 | tr -d ' ')
if [ -z "$fs_bytes" ] || [ "$fs_bytes" -lt 700000000 ]; then
  fail "the ext4 filesystem reports ${fs_bytes:-unknown} bytes; it was not grown to match the volume"
fi

grep -q "Monthly reports" /mnt/reports/reports-marker.txt 2>/dev/null || fail "reports-marker.txt is missing -- data did not survive"

echo "PASS: lv_reports is in /etc/fstab and was grown with its filesystem to about 800M, data intact"
exit 0
