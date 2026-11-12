#!/usr/bin/env bash
set -euo pipefail
for tool in iostat lsof; do command -v "$tool"; done
sudo test -b /dev/disk/by-id/virtio-s70m01-perf
