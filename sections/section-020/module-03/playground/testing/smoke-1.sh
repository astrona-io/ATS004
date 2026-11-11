#!/usr/bin/env bash
set -euo pipefail
for tool in iscsiadm; do command -v "$tool"; done
ip -o -4 addr show | grep -F " 10.10.60.5/" >/dev/null
