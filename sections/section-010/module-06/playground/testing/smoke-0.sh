#!/usr/bin/env bash
set -euo pipefail
for tool in lsblk blkid; do command -v "$tool"; done
sudo test -b /dev/disk/by-id/virtio-s015m02-a
