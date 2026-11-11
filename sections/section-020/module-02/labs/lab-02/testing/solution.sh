#!/usr/bin/env bash
set -euo pipefail
sudo tee /etc/exports >/dev/null <<'REFERENCE_FILE'
/srv/nfs/reports 127.0.0.1(ro,sync,no_subtree_check)
REFERENCE_FILE
sudo exportfs -ra
sudo tee -a /etc/fstab >/dev/null <<'FSTAB'
127.0.0.1:/srv/nfs/reports /mnt/nfs-reports nfs _netdev,nofail,ro 0 0
sshuser@localhost:/opt/remote-data /mnt/sshfs-logs fuse.sshfs _netdev,allow_other,IdentityFile=/root/.ssh/id_ed25519 0 0
FSTAB
sudo systemctl daemon-reload
sudo findmnt --verify
sudo mount -a
