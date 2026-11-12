#!/usr/bin/env bash
set -euo pipefail
for tool in swapon mkswap; do command -v "$tool"; done
sudo test -b /dev/disk/by-id/virtio-s40m02-swap
