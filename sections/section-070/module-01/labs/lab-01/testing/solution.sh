#!/usr/bin/env bash
set -euo pipefail
sudo mkdir -p /opt/course/audit
basename "$(readlink -f /dev/disk/by-id/virtio-lab071-disk2)" | sudo tee /opt/course/audit/slow_device.txt
