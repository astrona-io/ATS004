#!/usr/bin/env bash
set -euo pipefail
sudo mv /etc/systemd/system/srv-appdata.mount /etc/systemd/system/srv-appdata.mount.ci-saved
