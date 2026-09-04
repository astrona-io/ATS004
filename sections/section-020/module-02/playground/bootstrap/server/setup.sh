#!/usr/bin/env bash
# Bootstrap for the "server" VM: the NFS server.
# Environment prep only — no task, no grading. Installs and starts the NFS
# server and seeds the share directory, but writes NO export line: filling in
# /etc/exports is what the chapter's checkpoints have you do.
set -eu

export DEBIAN_FRONTEND=noninteractive

LAB_CIDR="10.10.20.0/24"

sudo mkdir -p /nfs/share
echo "shared report from server"  | sudo tee /nfs/share/report.txt >/dev/null
echo "shared notes from server"   | sudo tee /nfs/share/notes.txt  >/dev/null
sudo chmod 755 /nfs/share
sudo chmod 644 /nfs/share/*.txt

# --- Firewall -------------------------------------------------------------
# The base image ships firewalld, active, default zone "public": it permits
# only SSH and REJECTs everything else with "icmp admin-prohibited", which a
# client sees as "No route to host" when reaching rpcbind (111), nfsd (2049)
# or rpc.mountd (dynamic port). pg-net (10.10.20.0/24) is an isolated lab
# subnet, so put it in the "trusted" zone (target ACCEPT) — that covers every
# NFS-related port in one rule. Fall back to ufw/iptables on other images.
if command -v firewall-cmd >/dev/null 2>&1 && systemctl is-active --quiet firewalld; then
  sudo firewall-cmd --permanent --zone=trusted --add-source="$LAB_CIDR" || true
  sudo firewall-cmd --reload || true
elif command -v ufw >/dev/null 2>&1 && sudo ufw status | grep -q "Status: active"; then
  sudo ufw allow from "$LAB_CIDR" || true
elif command -v iptables >/dev/null 2>&1; then
  sudo iptables -C INPUT -s "$LAB_CIDR" -j ACCEPT 2>/dev/null \
    || sudo iptables -I INPUT 1 -s "$LAB_CIDR" -j ACCEPT 2>/dev/null || true
fi

# --- Exports -----------------------------------------------------------------
# Start with an empty exports file (keep only a comment) so the checkpoints
# add the export line themselves. Empty exports is fine: the daemons still
# run and register with rpcbind.
if [ ! -s /etc/exports ] || ! grep -q '/nfs/share' /etc/exports; then
  echo "# Add exports here, e.g.:  /nfs/share  10.10.20.0/24(ro,sync,no_subtree_check)" \
    | sudo tee /etc/exports >/dev/null
fi

# --- RPC stack -------------------------------------------------------------
# rpcbind MUST be listening before rpc.mountd starts; otherwise mountd fails
# to register and clients hit "clnt_create: RPC: Unable to receive" until a
# manual restart.
sudo systemctl enable --now rpcbind
sudo systemctl enable nfs-kernel-server
sudo systemctl restart nfs-kernel-server

# Confirm mountd + nfsd actually registered; retry a few times if not.
for _ in 1 2 3 4 5; do
  if rpcinfo -p localhost 2>/dev/null | grep -q 'mountd' \
     && rpcinfo -p localhost 2>/dev/null | grep -qE ' nfs$'; then
    break
  fi
  sleep 2
  sudo systemctl restart nfs-kernel-server
done

if ! rpcinfo -p localhost 2>/dev/null | grep -q 'mountd'; then
  echo "[playground] WARNING: rpc.mountd not registered with rpcbind" >&2
fi

if ! grep -q '[[:space:]]client$' /etc/hosts; then
  echo "10.10.20.5 client" | sudo tee -a /etc/hosts >/dev/null
fi

echo "[playground] server ready: mountd registered, lab subnet ${LAB_CIDR} trusted, /nfs/share seeded, /etc/exports empty."
