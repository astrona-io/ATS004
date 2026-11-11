#!/usr/bin/env bash
set -euo pipefail
sudo parted -s /dev/disk/by-id/virtio-lab011-raw mklabel gpt mkpart primary ext4 1MiB 1GiB
sudo udevadm settle
