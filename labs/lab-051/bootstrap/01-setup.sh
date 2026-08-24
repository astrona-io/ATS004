#!/usr/bin/env bash
set -eu

if ! command -v automount >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y autofs
fi

sudo mkdir -p /var/data/archive
sudo tee /var/data/archive/archive.txt > /dev/null <<'EOF'
This is an automated secure archive.
EOF
