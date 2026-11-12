#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -eu

DEV=/dev/disk/by-id/virtio-lab091-btrfs

for i in $(seq 1 30); do
  [ -e "$DEV" ] && break
  sleep 1
done

sudo udevadm settle --timeout=30 || true

if ! command -v mkfs.btrfs >/dev/null 2>&1; then
  sudo apt-get update -qq || true
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq btrfs-progs
fi
ASTRONA_STUDENT_SCRIPT
