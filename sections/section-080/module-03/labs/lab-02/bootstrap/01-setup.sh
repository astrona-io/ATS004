#!/usr/bin/env bash
# Bootstrap:
#  - /quota-ext: ext4 with usrquota, quotas ON, user "alice" already has
#    limits (the model user). bob and carol have none yet.
#  - /srv/xfs-teams: XFS mounted with gquota (XFS turns quotas on through the
#    mount option), group "engineers" exists with no limits.
# Copying the limits and setting the group limits and timer are the graded tasks.
set -eu

EXT=/dev/disk/by-id/virtio-lab080302-ext
XFS=/dev/disk/by-id/virtio-lab080302-xfs
for dev in "$EXT" "$XFS"; do
  for _ in $(seq 1 30); do
    [ -e "$dev" ] && break
    sleep 1
  done
done
sudo udevadm settle --timeout=30 || true

for user in alice bob carol; do
  id "$user" >/dev/null 2>&1 || sudo useradd -m "$user"
done
getent group engineers >/dev/null 2>&1 || sudo groupadd engineers
sudo usermod -aG engineers alice
sudo usermod -aG engineers bob

# --- ext4 with user quotas on ---
sudo mkfs.ext4 -q -L QEXT "$EXT"
sudo mkdir -p /quota-ext
EXT_UUID=$(sudo blkid -s UUID -o value "$EXT")
grep -q ' /quota-ext ' /etc/fstab || \
  echo "UUID=$EXT_UUID  /quota-ext  ext4  defaults,usrquota  0  2" | sudo tee -a /etc/fstab > /dev/null
sudo mount /quota-ext
sudo chmod 1777 /quota-ext
sudo quotacheck -cuv /quota-ext
sudo quotaon -uv /quota-ext
sudo setquota -u alice 40M 50M 0 0 /quota-ext

# --- XFS with group quotas on ---
sudo mkfs.xfs -q -L QXFS "$XFS"
sudo mkdir -p /srv/xfs-teams
XFS_UUID=$(sudo blkid -s UUID -o value "$XFS")
grep -q ' /srv/xfs-teams ' /etc/fstab || \
  echo "UUID=$XFS_UUID  /srv/xfs-teams  xfs  defaults,gquota  0  0" | sudo tee -a /etc/fstab > /dev/null
sudo mount /srv/xfs-teams
sudo mkdir -p /srv/xfs-teams/engineers
sudo chgrp engineers /srv/xfs-teams/engineers
sudo chmod 2775 /srv/xfs-teams/engineers
