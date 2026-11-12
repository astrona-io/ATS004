#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Bootstrap for the "terminal" VM: SSHFS client + NFS server role.
# Installs the tools the task needs but does NOT create the sshfs mount,
# the NFS export, or the /etc/fuse.conf opt-in -- those are the graded task.

set -eu

missing=()
for package in sshfs nfs-common nfs-kernel-server; do
  dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q 'install ok installed' || missing+=("$package")
done
if [ "${#missing[@]}" -gt 0 ]; then
  sudo apt-get update -y
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing[@]}"
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
# Allow the NFS server on this isolated practice subnet.
if sudo systemctl is-active --quiet firewalld; then
  sudo firewall-cmd --permanent --zone=trusted --add-source=10.10.40.0/24
  sudo firewall-cmd --zone=trusted --add-source=10.10.40.0/24
fi
ASTRONA_STUDENT_SCRIPT
