#!/usr/bin/env bash
# Bootstrap for the "client" VM: the NFS client.
# Environment prep only — no task, no grading. Installs the client tools and
# creates the mount point, but does NOT mount anything.
set -eu

export DEBIAN_FRONTEND=noninteractive

LAB_CIDR="10.10.20.0/24"

sudo mkdir -p /mnt/nfs

# The base image ships firewalld, active, and REJECTs non-SSH traffic. Trust
# the isolated lab subnet so server-side callbacks (NLM locking, NFSv4.0
# delegation) can reach this client. Fall back to ufw/iptables elsewhere.
if command -v firewall-cmd >/dev/null 2>&1 && systemctl is-active --quiet firewalld; then
  sudo firewall-cmd --permanent --zone=trusted --add-source="$LAB_CIDR" || true
  sudo firewall-cmd --reload || true
elif command -v ufw >/dev/null 2>&1 && sudo ufw status | grep -q "Status: active"; then
  sudo ufw allow from "$LAB_CIDR" || true
elif command -v iptables >/dev/null 2>&1; then
  sudo iptables -C INPUT -s "$LAB_CIDR" -j ACCEPT 2>/dev/null \
    || sudo iptables -I INPUT 1 -s "$LAB_CIDR" -j ACCEPT 2>/dev/null || true
fi

if ! grep -q '[[:space:]]server$' /etc/hosts; then
  echo "10.10.20.10 server" | sudo tee -a /etc/hosts >/dev/null
fi

echo "[playground] client ready: lab subnet ${LAB_CIDR} trusted, /mnt/nfs created."
