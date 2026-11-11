#!/usr/bin/env bash
set -euo pipefail
for tool in pvs lvs mdadm; do command -v "$tool"; done
sudo test -b /dev/disk/by-id/virtio-s090m01-a
sudo test -b /dev/disk/by-id/virtio-s090m01-b
sudo test -b /dev/disk/by-id/virtio-s090m01-c
sudo test -b /dev/disk/by-id/virtio-s090m01-d
