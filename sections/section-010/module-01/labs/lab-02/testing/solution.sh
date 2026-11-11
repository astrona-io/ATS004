#!/usr/bin/env bash
set -euo pipefail
sudo systemctl stop vault-keeper.service
sudo umount /mnt/locked-vault
