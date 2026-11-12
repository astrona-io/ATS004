#!/usr/bin/env bash
set -euo pipefail
sudo dd if=/dev/zero of=/swapfile bs=1M count=512 status=none
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo tee /tmp/swap-fstab >/dev/null <<'REFERENCE_FILE'
/swapfile none swap sw,pri=5 0 0
REFERENCE_FILE
cat /tmp/swap-fstab | sudo tee -a /etc/fstab
sudo swapon -p 5 /swapfile
