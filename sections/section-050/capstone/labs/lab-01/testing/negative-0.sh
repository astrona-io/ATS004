#!/usr/bin/env bash
set -euo pipefail
sudo mv /etc/auto.shared /etc/auto.shared.saved
sudo systemctl restart autofs
