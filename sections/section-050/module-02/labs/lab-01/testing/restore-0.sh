#!/usr/bin/env bash
set -euo pipefail
sudo mv /etc/auto.net.saved /etc/auto.net
sudo systemctl restart autofs
