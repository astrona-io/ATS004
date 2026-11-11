#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' '/mnt/auto /etc/auto.shared --timeout=300' | sudo tee -a /etc/auto.master
printf '%s\n' 'shared -fstype=nfs,rw data-001:/exports/shared' | sudo tee /etc/auto.shared
sudo chmod 644 /etc/auto.shared
sudo systemctl enable autofs
sudo systemctl restart autofs
ls /mnt/auto/shared
