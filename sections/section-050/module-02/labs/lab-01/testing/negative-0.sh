#!/usr/bin/env bash
set -euo pipefail
sudo mv /etc/auto.net /etc/auto.net.saved
sudo systemctl restart autofs
