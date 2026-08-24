#!/usr/bin/env bash
# Bootstrap for the "app-srv1" VM: SSHFS/NFS-export source + NFS client role.
# Fully pre-configures SSH access (this side is not graded) and creates the
# export source directory, but does NOT mount the NFS share -- that's the
# graded task on this VM.

set -eu

if ! command -v sshd >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y openssh-server
fi

if ! command -v mount.nfs >/dev/null 2>&1; then
  sudo apt-get install -y nfs-common
fi

sudo mkdir -p /data-export
echo "sample file from app-srv1" | sudo tee /data-export/hello.txt >/dev/null
sudo chmod 777 /data-export

sudo mkdir -p /nfs/terminal/share

# terminal's static IP on the lab-net network -- so "mount -t nfs
# terminal:/nfs/share ..." resolves without depending on the astrona
# runtime's own DNS conventions.
if ! grep -q '[[:space:]]terminal$' /etc/hosts; then
  echo "10.10.40.5 terminal" | sudo tee -a /etc/hosts >/dev/null
fi
