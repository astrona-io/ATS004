#!/usr/bin/env bash
# Bootstrap: installs autofs + nfs-common and prepares the mountpoint
# parent directory, but deliberately does NOT create any autofs map --
# configuring /etc/auto.master(.d) and the indirect map is the graded task.
set -eu

sudo mkdir -p /mnt/auto

# /etc/hosts entry so "data-001" resolves without relying on DNS.
if ! grep -q '[[:space:]]data-001$' /etc/hosts 2>/dev/null; then
  echo "10.10.50.5 data-001" | sudo tee -a /etc/hosts > /dev/null
fi

sudo systemctl enable autofs
sudo systemctl restart autofs
