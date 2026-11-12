#!/usr/bin/env bash
set -euo pipefail
sudo mkdir -p /opt/course/audit
find /usr/share/lab-links -xtype l | sort | sudo tee /opt/course/audit/symlink_report.txt
