#!/usr/bin/env bash
set -eu

if ! command -v sshfs >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y sshfs
fi

sudo sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf

if ! id "sshuser" >/dev/null 2>&1; then
  sudo useradd -m -s /bin/bash sshuser
  echo "sshuser:password123" | sudo chpasswd
fi

sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

sudo mkdir -p /opt/remote-data
sudo tee /opt/remote-data/welcome.txt > /dev/null <<'EOF'
Welcome to the secure ad-hoc remote share.
EOF
sudo chown -R sshuser:sshuser /opt/remote-data
