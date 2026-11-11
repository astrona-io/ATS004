#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
set -u

if ! sudo vgs vg_pool >/dev/null 2>&1; then
  echo "FAIL: Volume Group 'vg_pool' not found (step 2: 'sudo vgcreate vg_pool <pv1> <pv2>')"
  exit 1
fi

pv_count=$(sudo vgs --noheadings -o pv_count vg_pool 2>/dev/null | tr -d ' ')
if [ "$pv_count" != "2" ]; then
  echo "FAIL: vg_pool has $pv_count PV(s), expected 2 (step 2 asked to pool BOTH disks into one VG)"
  exit 1
fi

echo "PASS: vg_pool exists and pools exactly 2 PVs"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
