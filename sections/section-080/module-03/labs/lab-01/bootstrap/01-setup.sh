#!/usr/bin/env bash
# Bootstrap: mounts an XFS filesystem at /srv/xfs with uquota,pquota already
# active (XFS enables quotas purely by mount option -- no quotacheck, unlike
# ext4), seeds /srv/xfs/webdata, and creates test users alice/bob. Does NOT
# set any limits or define the project -- that is the graded task.
set -eu

DEV=/dev/disk/by-id/virtio-lab084-xfsquota
for i in $(seq 1 30); do
  [ -e "$DEV" ] && break
  sleep 1
done
sudo udevadm settle --timeout=30 || true

sudo mkfs.xfs -q -L XFSQUOTA "$DEV"
sudo mkdir -p /srv/xfs

UUID=$(sudo blkid -s UUID -o value "$DEV")
grep -q ' /srv/xfs ' /etc/fstab || \
  echo "UUID=$UUID  /srv/xfs  xfs  defaults,uquota,pquota  0  0" | sudo tee -a /etc/fstab > /dev/null

sudo mount /srv/xfs
sudo mkdir -p /srv/xfs/webdata
sudo chmod 1777 /srv/xfs/webdata

id alice >/dev/null 2>&1 || sudo useradd -m alice
id bob   >/dev/null 2>&1 || sudo useradd -m bob
