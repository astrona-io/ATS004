#!/usr/bin/env bash
# Bootstrap: builds a quota-ready ext4 filesystem at /quota (usrquota,grpquota
# in fstab) plus test users/group, but deliberately does NOT run quotacheck
# or quotaon -- turning quotas on and setting limits is the graded task.
set -eu

DEV=/dev/disk/by-id/virtio-lab083-quota
for i in $(seq 1 30); do
  [ -e "$DEV" ] && break
  sleep 1
done
sudo udevadm settle --timeout=30 || true

sudo mkfs.ext4 -q -L QUOTA "$DEV"
sudo mkdir -p /quota
UUID=$(sudo blkid -s UUID -o value "$DEV")
grep -q ' /quota ' /etc/fstab || \
  echo "UUID=$UUID  /quota  ext4  defaults,usrquota,grpquota  0  2" | sudo tee -a /etc/fstab > /dev/null
sudo mount /quota
sudo chmod 1777 /quota

id alice >/dev/null 2>&1 || sudo useradd -m alice
id bob   >/dev/null 2>&1 || sudo useradd -m bob
getent group team >/dev/null 2>&1 || sudo groupadd team
sudo usermod -aG team alice
sudo usermod -aG team bob

sudo mkdir -p /quota/alice /quota/bob /quota/team
sudo chown alice /quota/alice
sudo chown bob /quota/bob
sudo chgrp team /quota/team && sudo chmod 2775 /quota/team
