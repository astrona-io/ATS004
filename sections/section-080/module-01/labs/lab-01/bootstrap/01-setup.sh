#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -eu

if ! command -v quotacheck >/dev/null; then
  sudo apt-get update -y
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y quota
fi

DISK=/dev/disk/by-id/virtio-lab081-disk

for i in $(seq 1 30); do
  [ -e "$DISK" ] && break
  sleep 1
done

sudo udevadm settle --timeout=30 || true

sudo mkfs.ext4 -F "$DISK"
sudo mkdir -p /var/log/external_backup
sudo mount "$DISK" /var/log/external_backup

sudo dd if=/dev/zero of=/var/log/external_backup/heavy-file bs=1M count=1200 status=none

sudo mkdir -p /var/log/heavy_local_log
sudo dd if=/dev/zero of=/var/log/heavy_local_log/local-file bs=1M count=200 status=none

sudo mkdir -p /opt/course/audit
sudo chmod -R 777 /opt/course/audit
ASTRONA_STUDENT_SCRIPT
