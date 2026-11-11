#!/usr/bin/env bash
set -euo pipefail
sudo mkdir -p /opt/course/audit
sudo ls -1 /proc/$(pidof systemd-journald)/fd | wc -l | sudo tee /opt/course/audit/fd_count.txt
cat /proc/sys/fs/file-max | sudo tee /opt/course/audit/file_max.txt
