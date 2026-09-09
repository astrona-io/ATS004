#!/usr/bin/env bash
# Bootstrap: builds a quota-ready ext4 filesystem at /quota2, mounts it,
# creates carol, and this time also fully turns quotas ON and sets
# carol's limits -- the GRADED task here is the *consequences* of a
# limit (hitting it, and the grace period), not setting one up.
set -eu

DEV=/dev/disk/by-id/virtio-lab085-quota
for i in $(seq 1 30); do
  [ -e "$DEV" ] && break
  sleep 1
done
sudo udevadm settle --timeout=30 || true

sudo mkfs.ext4 -q -L QUOTA2 "$DEV"
sudo mkdir -p /quota2
UUID=$(sudo blkid -s UUID -o value "$DEV")
grep -q ' /quota2 ' /etc/fstab || \
  echo "UUID=$UUID  /quota2  ext4  defaults,usrquota,grpquota  0  2" | sudo tee -a /etc/fstab > /dev/null
sudo mount /quota2
sudo chmod 1777 /quota2

id carol >/dev/null 2>&1 || sudo useradd -m carol
sudo mkdir -p /quota2/carol
sudo chown carol /quota2/carol

sudo quotacheck -cugv /quota2
sudo quotaon -v /quota2
sudo setquota -u carol 20M 25M 0 0 /quota2
