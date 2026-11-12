#!/usr/bin/env bash
set -euo pipefail
sudo mv /etc/auto.direct /etc/auto.direct.saved
sudo systemctl restart autofs
