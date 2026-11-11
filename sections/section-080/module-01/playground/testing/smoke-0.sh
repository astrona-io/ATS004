#!/usr/bin/env bash
set -euo pipefail
for tool in find du; do command -v "$tool"; done
sudo test -b /dev/disk/by-id/virtio-s80m01-data
