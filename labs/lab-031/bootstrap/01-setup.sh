#!/usr/bin/env bash
set -eu
sudo udevadm settle --timeout=30 || true
