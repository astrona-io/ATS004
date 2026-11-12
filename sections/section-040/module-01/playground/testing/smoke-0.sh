#!/usr/bin/env bash
set -euo pipefail
for tool in swapon mkswap; do command -v "$tool"; done
