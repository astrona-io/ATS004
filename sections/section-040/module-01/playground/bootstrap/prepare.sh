#!/usr/bin/env bash
# OS prep for the "Swap Files" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
# Just reports the starting memory/swap picture and clears any stale swapfile
# from a previous run so the chapter starts from a known state.
set -euo pipefail

# Drop a leftover /swapfile if the environment was re-used.
if swapon --show=NAME --noheadings | grep -qx /swapfile; then
  sudo swapoff /swapfile || true
fi
[ -e /swapfile ] && sudo rm -f /swapfile

echo "[playground] memory and swap at start:"
free -h
echo
swapon --show || echo "(no swap active)"
echo
echo "[playground] root filesystem free space:"
df -h /
echo "[playground] ready. Create /swapfile with fallocate; the root fs is ext4."
