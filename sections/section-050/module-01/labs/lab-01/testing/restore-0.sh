#!/usr/bin/env bash
set -euo pipefail
sudo mv /etc/auto.direct.saved /etc/auto.direct
sudo systemctl restart autofs
