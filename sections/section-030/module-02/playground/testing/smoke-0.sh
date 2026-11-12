#!/usr/bin/env bash
set -euo pipefail
for tool in pvs lvs mdadm; do command -v "$tool"; done
sudo test -b /dev/disk/by-id/virtio-s30m02-a
sudo test -b /dev/disk/by-id/virtio-s30m02-b
sudo test -b /dev/disk/by-id/virtio-s30m02-c
