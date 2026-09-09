#!/usr/bin/env bash
set -eu
sudo swapoff -a || true
sudo rm -f /swapfile
