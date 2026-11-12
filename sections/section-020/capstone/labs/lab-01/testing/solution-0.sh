#!/usr/bin/env bash
set -euo pipefail
sudo chown student:student /app-srv1/data-export
sudo sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf
sshfs -o allow_other,rw app-srv1:/data-export /app-srv1/data-export
printf '%s
' '/nfs/share 10.10.40.0/24(ro,sync,no_subtree_check)' | sudo tee /etc/exports
sudo exportfs -ra
