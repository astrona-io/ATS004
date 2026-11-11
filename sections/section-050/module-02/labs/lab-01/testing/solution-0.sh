#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' '/mnt/net /etc/auto.net --timeout=120' | sudo tee -a /etc/auto.master
printf '%s\n' '* -fstype=nfs,ro 127.0.0.1:/var/nfs/exports/&' | sudo tee /etc/auto.net
sudo chmod 644 /etc/auto.net
sudo systemctl enable autofs
sudo systemctl restart autofs
ls /mnt/net/project-alpha
