#!/usr/bin/env bash
# OS prep for the "User and Group Disk Quotas" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
# Creates an ext4 filesystem mounted at /quota WITH the quota mount options
# and a persistent fstab entry, plus test users. It does NOT run quotacheck
# or quotaon — turning quotas on is the chapter's job.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
if ! command -v quotaon >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y quota
fi

DEV=/dev/disk/by-id/virtio-s100m01-q
for _ in $(seq 1 30); do [ -e "$DEV" ] && break; sleep 1; done
sudo udevadm settle --timeout=30 || true

if [ -e "$DEV" ]; then
  blkid "$DEV" >/dev/null 2>&1 || sudo mkfs.ext4 -q -L QUOTA "$DEV"
  sudo mkdir -p /quota
  UUID=$(sudo blkid -s UUID -o value "$DEV")
  [ -e /etc/fstab.orig ] || sudo cp /etc/fstab /etc/fstab.orig
  grep -q ' /quota ' /etc/fstab || \
    echo "UUID=$UUID  /quota  ext4  defaults,usrquota,grpquota  0  2" | sudo tee -a /etc/fstab >/dev/null
  grep -q ' /quota ' /proc/mounts || sudo mount /quota
  sudo chmod 1777 /quota
else
  echo "[playground] WARNING: $DEV did not appear."
fi

id alice >/dev/null 2>&1 || sudo useradd -m alice
id bob   >/dev/null 2>&1 || sudo useradd -m bob
getent group team >/dev/null 2>&1 || sudo groupadd team
sudo usermod -aG team alice
sudo usermod -aG team bob
sudo mkdir -p /quota/alice /quota/bob /quota/team
sudo chown alice /quota/alice
sudo chown bob /quota/bob
sudo chgrp team /quota/team && sudo chmod 2775 /quota/team

echo "[playground] ready. /quota is ext4, mounted with usrquota,grpquota (see /etc/fstab)."
echo "[playground] Users alice, bob; group team. Quotas are NOT on yet — run quotacheck / quotaon."
