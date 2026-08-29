#!/usr/bin/env bash
# Bootstrap for the "client" VM: the NFS client.
# Environment prep only — no task, no grading. Installs the client tools and
# creates the mount point, but does NOT mount anything.
set -eu

export DEBIAN_FRONTEND=noninteractive

if ! command -v mount.nfs >/dev/null 2>&1 || ! command -v showmount >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y nfs-common
fi

sudo mkdir -p /mnt/nfs

if ! grep -q '[[:space:]]server$' /etc/hosts; then
  echo "10.10.20.10 server" | sudo tee -a /etc/hosts >/dev/null
fi

echo "[playground] client ready: nfs-common + showmount installed, /mnt/nfs created."
