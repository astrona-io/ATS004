#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -eu

if ! command -v quotacheck >/dev/null; then
  sudo apt-get update -y
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y quota
fi

sudo mkdir -p /usr/share/lab-links
sudo mkdir -p /opt/course/audit
sudo chmod -R 777 /opt/course/audit

sudo mkdir -p /etc/alternative
sudo mkdir -p /opt/target

sudo ln -sf /etc/alternative/editor /usr/share/lab-links/link1
sudo ln -sf /var/log /usr/share/lab-links/link2
sudo ln -sf /opt/target/system /usr/share/lab-links/link3
sudo ln -sf /etc/hosts /usr/share/lab-links/link4
ASTRONA_STUDENT_SCRIPT
