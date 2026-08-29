#!/usr/bin/env bash
# OS prep for the "/sys & sysctl" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
# Just reports the starting state the chapter refers to.
set -euo pipefail

echo "[playground] root filesystem:"
findmnt -no SOURCE,FSTYPE /
echo
echo "[playground] baseline kernel tunable:"
sysctl net.ipv4.ip_forward
echo
echo "[playground] spare block device for /sys reads:"
lsblk -dn -o NAME,SIZE,SERIAL | grep -i s60m02 || true
echo
echo "[playground] ready. /proc, /sys, and sysctl are all available; a 1 GB spare disk is attached."
