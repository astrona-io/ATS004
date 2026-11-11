#!/usr/bin/env bash
set -euo pipefail
sudo btrfs property set -ts /mnt/vault-top/data-snapshot ro true
