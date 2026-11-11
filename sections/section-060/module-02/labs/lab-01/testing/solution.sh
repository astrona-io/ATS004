#!/usr/bin/env bash
set -euo pipefail
sudo tee /etc/sysctl.d/99-lab-forward.conf >/dev/null <<'REFERENCE_FILE'
net.ipv4.ip_forward=1
REFERENCE_FILE
sudo sysctl --system
