#!/usr/bin/env bash
# Checks that net.ipv4.ip_forward is live-enabled via /proc/sys.

set -u

value=$(cat /proc/sys/net/ipv4/ip_forward 2>/dev/null || echo "")

if [[ "$value" == "1" ]]; then
  echo "PASS: net.ipv4.ip_forward is live-enabled (1)"
  exit 0
else
  echo "FAIL: net.ipv4.ip_forward is '$value', expected '1'"
  exit 1
fi
