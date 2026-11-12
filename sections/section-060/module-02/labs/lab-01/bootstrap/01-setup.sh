#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -eu

sudo sysctl -w net.ipv4.ip_forward=0
sudo sed -i 's/^\s*net.ipv4.ip_forward\s*=.*/net.ipv4.ip_forward = 0/' /etc/sysctl.conf
ASTRONA_STUDENT_SCRIPT
