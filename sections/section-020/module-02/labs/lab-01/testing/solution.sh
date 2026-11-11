#!/usr/bin/env bash
set -euo pipefail
sudo tee /etc/exports >/dev/null <<'REFERENCE_FILE'
/var/nfs/public 127.0.0.1(rw,sync,no_subtree_check,no_root_squash)
REFERENCE_FILE
sudo exportfs -ra
sudo systemctl restart nfs-kernel-server
sudo mkdir -p /mnt/nfs-share
sudo mount -t nfs 127.0.0.1:/var/nfs/public /mnt/nfs-share
