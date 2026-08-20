#!/usr/bin/env bash
# Bootstrap for the "terminal" VM: SSHFS client + NFS server role.
# Installs the tools the task needs but does NOT create the sshfs mount,
# the NFS export, or the /etc/fuse.conf opt-in -- those are the graded task.

set -eu

if ! command -v sshfs >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y sshfs
fi

if ! command -v exportfs >/dev/null 2>&1; then
  sudo apt-get install -y nfs-kernel-server
fi
sudo systemctl enable --now nfs-kernel-server

sudo mkdir -p /app-srv1/data-export
sudo mkdir -p /nfs/share

# app-srv1's static IP on the lab-net network -- so "ssh app-srv1" and
# "showmount -e terminal" style hostname usage in the scenario resolves
# without depending on the astrona runtime's own DNS conventions.
if ! grep -q '[[:space:]]app-srv1$' /etc/hosts; then
  echo "10.10.40.10 app-srv1" | sudo tee -a /etc/hosts >/dev/null
fi
