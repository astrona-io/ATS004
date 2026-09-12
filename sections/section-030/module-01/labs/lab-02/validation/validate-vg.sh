#!/usr/bin/env bash
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
