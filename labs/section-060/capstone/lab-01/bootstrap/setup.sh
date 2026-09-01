#!/usr/bin/env bash
# Bootstrap: makes sure net.ipv4.ip_forward starts disabled and unpersisted
# (so the lab's "temporarily enable it" task has a clean starting point and
# a meaningful "not persisted" check), and deploys a small long-running
# target process with a deterministic, non-trivial number of open file
# descriptors, whose PID is published at /opt/course/target.pid.

set -eu

# --- ip_forward: start clean ---
sudo sysctl -w net.ipv4.ip_forward=0 >/dev/null
sudo rm -f /etc/sysctl.d/99-ip-forward.conf
sudo sed -i '/net\.ipv4\.ip_forward/d' /etc/sysctl.conf 2>/dev/null || true

# --- target process with a known FD count ---
sudo mkdir -p /opt/course

sudo tee /usr/local/bin/lab-target-process.py > /dev/null <<'EOF'
#!/usr/bin/env python3
# Opens a handful of distinct file descriptors and then just sleeps,
# so /proc/<PID>/fd has a deterministic, non-trivial count to read.
import os
import tempfile
import time

fds = []
for i in range(6):
    path = f"/tmp/lab-target-fd-{i}"
    f = open(path, "w")
    fds.append(f)

r, w = os.pipe()

with open("/opt/course/target.pid", "w") as pf:
    pf.write(str(os.getpid()))

while True:
    time.sleep(3600)
EOF
sudo chmod +x /usr/local/bin/lab-target-process.py

sudo tee /etc/systemd/system/lab-target-process.service > /dev/null <<'EOF'
[Unit]
Description=Lab target process for /proc/<PID>/fd practice
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/bin/lab-target-process.py
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now lab-target-process
