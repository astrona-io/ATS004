#!/usr/bin/env bash
# OS prep for the "XFS Quotas and Project Quotas" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
# XFS quotas are enabled purely by mount option, so the filesystem comes up
# quota-ready. The chapter defines the project and the limits.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

DEV=/dev/disk/by-id/virtio-s100m02-x
for _ in $(seq 1 30); do [ -e "$DEV" ] && break; sleep 1; done
sudo udevadm settle --timeout=30 || true

if [ -e "$DEV" ]; then
  blkid "$DEV" >/dev/null 2>&1 || sudo mkfs.xfs -q -L XFSQUOTA "$DEV"
  sudo mkdir -p /srv/xfs
  UUID=$(sudo blkid -s UUID -o value "$DEV")
  [ -e /etc/fstab.orig ] || sudo cp /etc/fstab /etc/fstab.orig
  grep -q ' /srv/xfs ' /etc/fstab || \
    echo "UUID=$UUID  /srv/xfs  xfs  defaults,uquota,pquota  0  0" | sudo tee -a /etc/fstab >/dev/null
  grep -q ' /srv/xfs ' /proc/mounts || sudo mount /srv/xfs
  sudo chmod 1777 /srv/xfs
else
  echo "[playground] WARNING: $DEV did not appear."
fi

id alice >/dev/null 2>&1 || sudo useradd -m alice
id bob   >/dev/null 2>&1 || sudo useradd -m bob
sudo mkdir -p /srv/xfs/webdata
sudo chmod 1777 /srv/xfs/webdata

echo "[playground] ready. /srv/xfs is XFS, mounted with uquota,pquota (see /etc/fstab)."
echo "[playground] Directory tree /srv/xfs/webdata; users alice, bob."
echo "[playground] No /etc/projects, /etc/projid, or limits yet — the chapter adds them."
