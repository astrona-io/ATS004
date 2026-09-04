#!/usr/bin/env bash
set -eu

sudo mkdir -p /var/data/archive
sudo tee /var/data/archive/archive.txt > /dev/null <<'EOF'
This is an automated secure archive.
EOF
