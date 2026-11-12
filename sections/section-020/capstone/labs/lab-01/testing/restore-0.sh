#!/usr/bin/env bash
set -euo pipefail
sudo mount -t nfs -o ro terminal:/nfs/share /nfs/terminal/share
