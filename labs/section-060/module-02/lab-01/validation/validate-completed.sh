#!/usr/bin/env bash
set -u

live_val=$(sysctl -n net.ipv4.ip_forward)
if [ "$live_val" != "1" ]; then
  echo "FAIL: Live kernel value net.ipv4.ip_forward is '$live_val', expected '1'"
  exit 1
fi

if ! grep -rE "^\s*net.ipv4.ip_forward\s*=\s*1" /etc/sysctl.conf /etc/sysctl.d/ >/dev/null 2>&1; then
  echo "FAIL: Persistent configuration 'net.ipv4.ip_forward = 1' not found in sysctl.conf or sysctl.d/"
  exit 1
fi

echo "PASS: IPv4 routing forwarding is active and persistently configured"
exit 0
