#!/usr/bin/env bash
# Bootstrap for the "client" VM: the autofs client.
# Environment prep only — no task, no grading. Installs the tools and keeps a
# pristine /etc/auto.master; writes NO map entries (that is the chapter's job).
set -eu

export DEBIAN_FRONTEND=noninteractive

sudo systemctl enable --now autofs

if ! grep -q '[[:space:]]nfs$' /etc/hosts; then
  echo "10.10.50.10 nfs" | sudo tee -a /etc/hosts >/dev/null
fi

[ -e /etc/auto.master.orig ] || sudo cp /etc/auto.master /etc/auto.master.orig

echo "[playground] client ready: autofs running, 'nfs' in /etc/hosts."
