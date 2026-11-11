#!/usr/bin/env bash
set -euo pipefail
for tool in lsblk blkid; do command -v "$tool"; done
sudo test -b /dev/disk/by-id/virtio-s010m09-a
sudo test -b /dev/disk/by-id/virtio-s010m09-b
