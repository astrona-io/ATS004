#!/usr/bin/env bash
# Bootstrap: ensures the VM starts with genuinely zero swap active (matching
# the scenario's "no swap configured at all"), and partitions the extra disk
# into one unformatted partition for the task to turn into swap itself.
#
# IMPORTANT: astrona-cli's extraDisks are NOT guaranteed to land on
# /dev/vdb -- in practice they can enumerate BEFORE the main disk, so a raw
# device-letter guess risks partitioning the VM's own root disk. This disk
# is resolved via its `serial` (set in config.yaml) through the kernel's
# stable /dev/disk/by-id/virtio-<serial> path instead.

set -eu

# Deactivate and strip any swap the base image might already carry.
sudo swapoff -a || true
sudo sed -i.bak '/\sswap\s/d' /etc/fstab

BYID=/dev/disk/by-id/virtio-lab040-swap
for i in $(seq 1 30); do
  [ -e "$BYID" ] && break
  sleep 1
done
sudo udevadm settle --timeout=30 || true

# Resolve the by-id symlink to the real kernel device name (e.g. /dev/vda)
# so we can address its first partition (e.g. /dev/vda1) -- partition
# device nodes are always <parent-device><N>, regardless of by-id naming.
DISK=$(readlink -f "$BYID")
PART="${DISK}1"

if [ ! -e "$PART" ]; then
  sudo parted -s "$DISK" mklabel gpt mkpart primary linux-swap 0% 100%
  sudo partprobe "$DISK"
fi
