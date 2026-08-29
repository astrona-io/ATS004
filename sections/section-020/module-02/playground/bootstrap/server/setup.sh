#!/usr/bin/env bash
# Bootstrap for the "server" VM: the NFS server.
# Environment prep only — no task, no grading. Installs and starts the NFS
# server and seeds the share directory, but writes NO export line: filling in
# /etc/exports is what the chapter's checkpoints have you do.
set -eu

export DEBIAN_FRONTEND=noninteractive

if ! command -v exportfs >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y nfs-kernel-server
fi
sudo systemctl enable --now nfs-kernel-server

sudo mkdir -p /nfs/share
echo "shared report from server"  | sudo tee /nfs/share/report.txt >/dev/null
echo "shared notes from server"   | sudo tee /nfs/share/notes.txt  >/dev/null
sudo chmod 755 /nfs/share
sudo chmod 644 /nfs/share/*.txt

# Start with an empty exports file (keep only a comment) so the checkpoints
# add the export line themselves.
if [ ! -s /etc/exports ] || ! grep -q '/nfs/share' /etc/exports; then
  echo "# Add exports here, e.g.:  /nfs/share  10.10.20.0/24(ro,sync,no_subtree_check)" \
    | sudo tee /etc/exports >/dev/null
  sudo exportfs -ra || true
fi

if ! grep -q '[[:space:]]client$' /etc/hosts; then
  echo "10.10.20.5 client" | sudo tee -a /etc/hosts >/dev/null
fi

echo "[playground] server ready: nfs-kernel-server running, /nfs/share seeded, /etc/exports empty."
