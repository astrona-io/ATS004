#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Lab bootstrap for the "server" VM: an iSCSI target with one empty disk.
# Prepares the starting state only, never the graded result. Packages are
# installed with apt at start-up. Not run or tested by the course authors.
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

install_packages tgt

sudo mkdir -p /srv/iscsi
[ -e /srv/iscsi/cargo.img ] || sudo truncate -s 1G /srv/iscsi/cargo.img

sudo tee /etc/tgt/conf.d/cargo.conf >/dev/null <<TGT
<target ${TARGET_NAME}>
    backing-store /srv/iscsi/cargo.img
</target>
TGT
sudo systemctl enable tgt
sudo systemctl restart tgt

if ! grep -q '[[:space:]]client$' /etc/hosts; then
  echo "10.10.60.5 client" | sudo tee -a /etc/hosts >/dev/null
fi

echo "[lab] server ready: iSCSI target ${TARGET_NAME} on 10.10.60.10:3260."
ASTRONA_STUDENT_SCRIPT
