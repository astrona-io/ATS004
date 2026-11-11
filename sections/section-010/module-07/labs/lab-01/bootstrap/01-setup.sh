#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -eu

DEV=/dev/disk/by-id/virtio-lab017-media

for i in $(seq 1 30); do
  [ -e "$DEV" ] && break
  sleep 1
done

sudo udevadm settle --timeout=30 || true
ASTRONA_STUDENT_SCRIPT
