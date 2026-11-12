#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' '/- /etc/auto.direct --timeout=60' | sudo tee -a /etc/auto.master
printf '%s\n' '/mnt/secure_archive -fstype=bind :/var/data/archive' | sudo tee /etc/auto.direct
sudo chmod 644 /etc/auto.direct
sudo systemctl enable autofs
sudo systemctl restart autofs
ls /mnt/secure_archive
