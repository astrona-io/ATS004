#!/usr/bin/env bash
# Checks that net.ipv4.ip_forward=1 was not written into any persistent
# sysctl config file, confirming the change was live/temporary only.

set -u

hits=0

if [[ -f /etc/sysctl.conf ]] && grep -Eq '^\s*net\.ipv4\.ip_forward\s*=\s*1\s*$' /etc/sysctl.conf; then
  hits=$((hits + 1))
fi

if compgen -G "/etc/sysctl.d/*.conf" > /dev/null; then
  if grep -Eqr '^\s*net\.ipv4\.ip_forward\s*=\s*1\s*$' /etc/sysctl.d/*.conf 2>/dev/null; then
    hits=$((hits + 1))
  fi
fi

if [[ "$hits" -eq 0 ]]; then
  echo "PASS: net.ipv4.ip_forward=1 not found in any persistent sysctl config"
  exit 0
else
  echo "FAIL: net.ipv4.ip_forward=1 found in a persistent sysctl config file (expected a live-only, temporary change)"
  exit 1
fi
