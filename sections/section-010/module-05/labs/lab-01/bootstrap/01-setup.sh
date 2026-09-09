#!/usr/bin/env bash
set -eu

DEV=/dev/disk/by-id/virtio-lab015-data1

for i in $(seq 1 30); do
  [ -e "$DEV" ] && break
  sleep 1
done

sudo udevadm settle --timeout=30 || true
