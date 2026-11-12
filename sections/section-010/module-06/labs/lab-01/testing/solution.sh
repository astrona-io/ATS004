#!/usr/bin/env bash
set -euo pipefail
sudo mkfs.ext4 /dev/disk/by-id/virtio-lab016-data1
uuid=$(sudo blkid -s UUID -o value /dev/disk/by-id/virtio-lab016-data1)
sudo mkdir -p /srv/appdata
sudo tee /etc/systemd/system/srv-appdata.mount >/dev/null <<REFERENCE_FILE
[Unit]
Description=Application data filesystem at /srv/appdata

[Mount]
What=UUID=${uuid}
Where=/srv/appdata
Type=ext4
Options=defaults,nofail

[Install]
WantedBy=multi-user.target
REFERENCE_FILE
sudo tee /etc/systemd/system/srv-appdata.automount >/dev/null <<'REFERENCE_FILE'
[Unit]
Description=Automount for /srv/appdata

[Automount]
Where=/srv/appdata
TimeoutIdleSec=30

[Install]
WantedBy=multi-user.target
REFERENCE_FILE
sudo systemctl daemon-reload
sudo systemctl enable --now srv-appdata.automount
ls /srv/appdata
