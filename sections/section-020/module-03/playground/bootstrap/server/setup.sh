#!/usr/bin/env bash
# Bootstrap for the "server" VM: iSCSI target (tgt) and NBD server.
# Environment prep only - no task, no grading. Packages are installed with apt
# at start-up. This script has not been run or tested by the course authors.
set -eu

export DEBIAN_FRONTEND=noninteractive

LAB_CIDR="10.10.60.0/24"
TARGET_NAME="iqn.2026-01.io.astrona:storage.cargo"

# Packages come from the Ubuntu archive at start-up, so retry on a slow network.
install_packages() {
  for attempt in 1 2 3 4 5; do
    if sudo apt-get update -qq && sudo apt-get install -y -qq "$@"; then
      return 0
    fi
    sleep 5
  done
  echo "WARNING: could not install: $*" >&2
  return 1
}

# The base image ships firewalld, active, and it rejects every port except
# SSH. The lab subnet is isolated, so trust it. Fall back to ufw/iptables.
if command -v firewall-cmd >/dev/null 2>&1 && systemctl is-active --quiet firewalld; then
  sudo firewall-cmd --permanent --zone=trusted --add-source="$LAB_CIDR" || true
  sudo firewall-cmd --reload || true
elif command -v ufw >/dev/null 2>&1 && sudo ufw status | grep -q "Status: active"; then
  sudo ufw allow from "$LAB_CIDR" || true
elif command -v iptables >/dev/null 2>&1; then
  sudo iptables -C INPUT -s "$LAB_CIDR" -j ACCEPT 2>/dev/null \
    || sudo iptables -I INPUT 1 -s "$LAB_CIDR" -j ACCEPT 2>/dev/null || true
fi

install_packages tgt nbd-server

# --- Backing files: the "raw disks" the server hands out -----------------
sudo mkdir -p /srv/iscsi /srv/nbd
[ -e /srv/iscsi/cargo.img ] || sudo truncate -s 1G /srv/iscsi/cargo.img
[ -e /srv/nbd/cargo.img ]   || sudo truncate -s 512M /srv/nbd/cargo.img

# --- iSCSI target (tgt) ----------------------------------------------------
# One target with one disk behind it. No initiator restriction (lab network).
sudo tee /etc/tgt/conf.d/cargo.conf >/dev/null <<TGT
<target ${TARGET_NAME}>
    backing-store /srv/iscsi/cargo.img
</target>
TGT
sudo systemctl enable tgt
sudo systemctl restart tgt

# --- NBD server --------------------------------------------------------------
# One named export "cargo". Run as root so it can read the backing file.
sudo mkdir -p /etc/nbd-server
sudo tee /etc/nbd-server/config >/dev/null <<NBD
[generic]
    user = root
    group = root
[cargo]
    exportname = /srv/nbd/cargo.img
NBD
sudo systemctl enable nbd-server
sudo systemctl restart nbd-server || true

if ! grep -q '[[:space:]]client$' /etc/hosts; then
  echo "10.10.60.5 client" | sudo tee -a /etc/hosts >/dev/null
fi

echo "[playground] server ready: iSCSI target ${TARGET_NAME} on port 3260, NBD export 'cargo' on port 10809."
