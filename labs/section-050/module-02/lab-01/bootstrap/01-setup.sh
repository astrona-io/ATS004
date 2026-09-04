#!/usr/bin/env bash
set -eu

sudo mkdir -p /var/nfs/exports/project-alpha
sudo mkdir -p /var/nfs/exports/project-beta

sudo tee /var/nfs/exports/project-alpha/alpha.txt > /dev/null <<'EOF'
Project Alpha Secure Files.
EOF

sudo tee /var/nfs/exports/project-beta/beta.txt > /dev/null <<'EOF'
Project Beta Secure Files.
EOF

sudo tee /etc/exports > /dev/null <<'EOF'
/var/nfs/exports/project-alpha *(ro,sync,no_subtree_check)
/var/nfs/exports/project-beta *(ro,sync,no_subtree_check)
EOF

sudo systemctl restart nfs-kernel-server
