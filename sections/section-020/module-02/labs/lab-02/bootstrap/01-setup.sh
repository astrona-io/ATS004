#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Bootstrap: one machine plays both ships. It prepares
#  - an SSH login (sshuser) that root can reach with a key, for the SSHFS mount
#  - an NFS export that is deliberately offered to the WRONG network, so the
#    first mount attempt is refused (the broken part the learner must fix)
# It does NOT write any /etc/fstab line and does NOT mount anything.
set -eu

missing=()
for package in nfs-common nfs-kernel-server; do
  dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q 'install ok installed' || missing+=("$package")
done
if [ "${#missing[@]}" -gt 0 ]; then
  sudo apt-get update -y
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing[@]}"
fi

# --- SSHFS side ---
if ! id sshuser >/dev/null 2>&1; then
  sudo useradd -m -s /bin/bash sshuser
fi
sudo mkdir -p /opt/remote-data
echo "Welcome to the persistent SSHFS share." | sudo tee /opt/remote-data/welcome.txt > /dev/null
sudo chown -R sshuser:sshuser /opt/remote-data

sudo install -d -m 700 /root/.ssh
[ -f /root/.ssh/id_ed25519 ] || sudo ssh-keygen -q -t ed25519 -N '' -f /root/.ssh/id_ed25519
sudo install -d -m 700 -o sshuser -g sshuser /home/sshuser/.ssh
sudo cat /root/.ssh/id_ed25519.pub | sudo tee /home/sshuser/.ssh/authorized_keys > /dev/null
sudo chown sshuser:sshuser /home/sshuser/.ssh/authorized_keys
sudo chmod 600 /home/sshuser/.ssh/authorized_keys

sudo systemctl enable --now ssh
for _ in $(seq 1 20); do
  sudo ssh-keyscan -H localhost 127.0.0.1 2>/dev/null | sudo tee /root/.ssh/known_hosts > /dev/null
  [ -s /root/.ssh/known_hosts ] && break
  sleep 1
done

# --- NFS side ---
sudo mkdir -p /srv/nfs/reports
echo "Quarterly report: all holds counted." | sudo tee /srv/nfs/reports/q4-report.txt > /dev/null
sudo chmod -R 755 /srv/nfs/reports
echo '/srv/nfs/reports 10.99.0.0/24(ro,sync,no_subtree_check)' | sudo tee /etc/exports > /dev/null
sudo systemctl enable --now nfs-kernel-server
sudo exportfs -ra

# --- Empty hatches ---
sudo mkdir -p /mnt/nfs-reports /mnt/sshfs-logs
ASTRONA_STUDENT_SCRIPT
