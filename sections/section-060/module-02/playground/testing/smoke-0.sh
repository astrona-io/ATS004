#!/usr/bin/env bash
set -euo pipefail
for tool in sysctl; do command -v "$tool"; done
sudo test -b /dev/disk/by-id/virtio-s60m02-disk
