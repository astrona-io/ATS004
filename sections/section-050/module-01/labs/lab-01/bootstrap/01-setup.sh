#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -eu

sudo mkdir -p /var/data/archive
sudo tee /var/data/archive/archive.txt > /dev/null <<'EOF'
This is an automated secure archive.
EOF
ASTRONA_STUDENT_SCRIPT
