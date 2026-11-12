#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Bootstrap for the "client" VM: NBD client and iSCSI initiator tools.
# Environment prep only - no task, no grading. Nothing is connected or mounted.
# Packages are installed with apt at start-up. Not run or tested by the authors.
set -eu

export DEBIAN_FRONTEND=noninteractive

LAB_CIDR="10.10.60.0/24"

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

install_packages nbd-client open-iscsi

sudo mkdir -p /mnt/cargo
sudo systemctl enable --now iscsid || true

if ! grep -q '[[:space:]]server$' /etc/hosts; then
  echo "10.10.60.10 server" | sudo tee -a /etc/hosts >/dev/null
fi

echo "[playground] client ready: nbd-client and open-iscsi installed, /mnt/cargo created."
ASTRONA_STUDENT_SCRIPT
