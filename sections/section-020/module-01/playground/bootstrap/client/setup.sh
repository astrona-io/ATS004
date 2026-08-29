#!/usr/bin/env bash
# Bootstrap for the "client" VM: SSHFS client.
# Environment prep only — no task, no grading. Installs the tools and wires
# passwordless root SSH to srv, but does NOT create the sshfs mount: that is
# what the chapter's checkpoints have you do.
set -eu

export DEBIAN_FRONTEND=noninteractive

if ! command -v sshfs >/dev/null 2>&1 || ! command -v sshpass >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y sshfs sshpass
fi

# FUSE opt-in so that `-o allow_other` is permitted for non-root mounts too.
if ! grep -q '^user_allow_other' /etc/fuse.conf 2>/dev/null; then
  echo 'user_allow_other' | sudo tee -a /etc/fuse.conf >/dev/null
fi

# A second unprivileged local user for the allow_other / default_permissions demo.
if ! id bob >/dev/null 2>&1; then
  sudo useradd -m -s /bin/bash bob
fi

sudo mkdir -p /mnt/remote

if ! grep -q '[[:space:]]srv$' /etc/hosts; then
  echo "10.10.20.10 srv" | sudo tee -a /etc/hosts >/dev/null
fi

# Passwordless root SSH client -> srv. Wait for srv's sshd, then push a key.
sudo mkdir -p /root/.ssh
sudo chmod 700 /root/.ssh
[ -f /root/.ssh/id_ed25519 ] || sudo ssh-keygen -t ed25519 -N '' -f /root/.ssh/id_ed25519

for _ in $(seq 1 60); do
  if sudo ssh-keyscan -T 5 srv 2>/dev/null | sudo tee /root/.ssh/known_hosts >/dev/null && \
     [ -s /root/.ssh/known_hosts ]; then
    break
  fi
  sleep 3
done

# The LFCS image ships root password "AstronaLab2024!" with password login enabled.
sudo sshpass -p 'AstronaLab2024!' ssh-copy-id -o StrictHostKeyChecking=no \
  -i /root/.ssh/id_ed25519.pub root@srv || \
  echo "[playground] WARNING: could not push SSH key to srv automatically; " \
       "you may be prompted for the password 'AstronaLab2024!' on first ssh/sshfs."

echo "[playground] client ready: sshfs + sshpass installed, user 'bob' added, /mnt/remote created."
