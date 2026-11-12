#!/usr/bin/env bash
set -euo pipefail
sudo mkdir -p /opt/course/audit
printf '%s\n' /var/log/heavy_local_log | sudo tee /opt/course/audit/heavy_dirs.txt
