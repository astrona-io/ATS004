#!/usr/bin/env bash
set -euo pipefail
sudo dd if=/dev/disk/by-id/virtio-lab018-source of=/dev/disk/by-id/virtio-lab018-clone bs=4M status=none
sync
