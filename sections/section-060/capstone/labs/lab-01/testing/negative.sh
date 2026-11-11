#!/usr/bin/env bash
set -euo pipefail
sudo sysctl -w net.ipv4.ip_forward=0
