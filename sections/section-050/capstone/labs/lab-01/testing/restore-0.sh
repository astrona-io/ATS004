#!/usr/bin/env bash
set -euo pipefail
sudo mv /etc/auto.shared.saved /etc/auto.shared
sudo systemctl restart autofs
