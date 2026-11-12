#!/usr/bin/env bash
set -euo pipefail
for tool in automount; do command -v "$tool"; done
ip -o -4 addr show | grep -F " 10.10.50.5/" >/dev/null
