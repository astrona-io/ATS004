#!/usr/bin/env bash
set -euo pipefail
printf x | sudo dd of=/dev/disk/by-id/virtio-lab018-clone bs=1 seek=1048576 conv=notrunc status=none
