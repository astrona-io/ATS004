#!/usr/bin/env bash
# Bootstrap for the "srv" VM: a plain SSH host that exposes /srv/logs.
# Environment prep only — no task, no grading. Does NOT create any mount.
set -eu

if ! command -v sshd >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y openssh-server
fi
sudo systemctl enable --now ssh || sudo systemctl enable --now sshd || true

sudo mkdir -p /srv/logs
echo "srv app.log line 1"        | sudo tee /srv/logs/app.log    >/dev/null
echo "srv access.log line 1"     | sudo tee /srv/logs/access.log >/dev/null
echo "credentials: hunter2"      | sudo tee /srv/logs/secret.txt >/dev/null
# Owned by the login user (the identity the client's non-root sshfs connects as),
# mode 600 so it is not world-readable. The sshfs process can read it on srv;
# other local users on the client cannot, unless -o default_permissions is off.
LOGIN_USER="$(id -un)"
sudo chown "$LOGIN_USER:$LOGIN_USER" /srv/logs/secret.txt
sudo chmod 600 /srv/logs/secret.txt        # only the owner can read this at the server
sudo chmod 644 /srv/logs/app.log /srv/logs/access.log
sudo chmod 755 /srv/logs

# Static name for the client, so scenario hostnames resolve without relying on
# the runtime's own DNS conventions.
if ! grep -q '[[:space:]]client$' /etc/hosts; then
  echo "10.10.20.5 client" | sudo tee -a /etc/hosts >/dev/null
fi

echo "[playground] srv ready: /srv/logs seeded (secret.txt is root-only, mode 600)."
