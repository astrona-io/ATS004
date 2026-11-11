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

sudo mkdir -p /var/nfs/public
sudo tee /var/nfs/public/shared-doc.txt > /dev/null <<'EOF'
This is shared corporate data. Do not alter.
EOF
sudo chmod -R 755 /var/nfs/public
sudo chown -R nobody:nogroup /var/nfs/public

sudo systemctl enable --now nfs-kernel-server
ASTRONA_STUDENT_SCRIPT
