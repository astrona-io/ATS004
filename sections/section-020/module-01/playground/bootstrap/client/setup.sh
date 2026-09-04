#!/usr/bin/env bash
# Bootstrap for the "client" VM: SSHFS client.
# Environment prep only — no task, no grading. Installs the tools and pre-creates
# the mount point, but does NOT create the sshfs mount: that is what the
# chapter's checkpoints have you do. All mounts in this module are non-root.
set -eu

export DEBIAN_FRONTEND=noninteractive

# FUSE opt-in so a non-root `sshfs -o allow_other` mount is permitted.
if ! grep -q '^user_allow_other' /etc/fuse.conf 2>/dev/null; then
  echo 'user_allow_other' | sudo tee -a /etc/fuse.conf >/dev/null
fi

# A second unprivileged local user for the allow_other / default_permissions demo.
if ! id bob >/dev/null 2>&1; then
  sudo useradd -m -s /bin/bash bob
fi

# Mount point in the login user's home — no sudo needed to create or mount here.
mkdir -p "$HOME/remote"

if ! grep -q '[[:space:]]srv$' /etc/hosts; then
  echo "10.10.20.10 srv" | sudo tee -a /etc/hosts >/dev/null
fi

# Passwordless SSH client -> srv for the login user is wired by Astrona's
# `sshAccess: [srv]` in config.yaml, so `sshfs srv:...` needs no key setup here.
# Just pre-accept srv's host key so the first `sshfs` does not prompt.
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
for _ in $(seq 1 60); do
  if ssh-keyscan -T 5 srv 2>/dev/null >> "$HOME/.ssh/known_hosts" && \
     grep -q srv "$HOME/.ssh/known_hosts"; then
    break
  fi
  sleep 3
done
sort -u "$HOME/.ssh/known_hosts" -o "$HOME/.ssh/known_hosts" 2>/dev/null || true

echo "[playground] client ready: user 'bob' added, ~/remote created."
