#!/usr/bin/env bash
set -euo pipefail
for tool in sshfs mount.nfs; do command -v "$tool"; done
ip -o -4 addr show | grep -F " 10.10.60.10/" >/dev/null
