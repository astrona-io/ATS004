#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -eu

sudo mkdir -p /var/nfs/public
sudo tee /var/nfs/public/shared-doc.txt > /dev/null <<'EOF'
This is shared corporate data. Do not alter.
EOF
sudo chmod -R 755 /var/nfs/public
sudo chown -R nobody:nogroup /var/nfs/public

sudo systemctl enable --now nfs-kernel-server
ASTRONA_STUDENT_SCRIPT
