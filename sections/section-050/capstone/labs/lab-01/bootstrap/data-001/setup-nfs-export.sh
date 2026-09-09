#!/usr/bin/env bash
# Bootstrap: fully pre-configures data-001 as the NFS export source. Not
# part of the graded task -- the graded task is app-srv1's autofs config.
set -eu

sudo mkdir -p /exports/shared
sudo chmod 0755 /exports/shared
echo "hello from data-001" | sudo tee /exports/shared/welcome.txt > /dev/null
sudo dd if=/dev/urandom of=/exports/shared/sample.bin bs=1K count=64 2>/dev/null

# lab-net is 10.10.50.0/24 -- see config.yaml.
EXPORT_LINE="/exports/shared 10.10.50.0/24(rw,sync,no_subtree_check,no_root_squash)"
if ! grep -qF "/exports/shared" /etc/exports 2>/dev/null; then
  echo "$EXPORT_LINE" | sudo tee -a /etc/exports > /dev/null
fi

sudo systemctl enable --now nfs-kernel-server
sudo exportfs -ra
