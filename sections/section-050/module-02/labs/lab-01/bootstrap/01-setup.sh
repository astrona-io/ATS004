#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -eu

missing=()
for package in nfs-common nfs-kernel-server; do
  dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q 'install ok installed' || missing+=("$package")
done
if [ "${#missing[@]}" -gt 0 ]; then
  sudo apt-get update -y
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing[@]}"
fi

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
ASTRONA_STUDENT_SCRIPT
