#!/usr/bin/env bash
set -eu

sudo mkdir -p /opt/lab-scripts
sudo mkdir -p /opt/course/audit
sudo chmod -R 777 /opt/course/audit

sudo tee /opt/lab-scripts/rogue_writer.py > /dev/null <<'EOF'
import time
import os

filepath = "/var/log/rogue_activity.log"
with open(filepath, "w") as f:
    while True:
        f.write("REDUNDANT LOG METRIC INFORMATION GENERATING LARGE FILESYSTEM WRITES SYSTEM WIDE\n" * 1000)
        f.flush()
        os.fsync(f.fileno())
        time.sleep(0.05)
EOF

sudo tee /etc/systemd/system/rogue-writer.service > /dev/null <<'EOF'
[Unit]
Description=Rogue heavy writer service
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/lab-scripts/rogue_writer.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now rogue-writer
