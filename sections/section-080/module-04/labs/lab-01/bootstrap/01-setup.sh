#!/usr/bin/env bash
set -eu

sudo mkdir -p /usr/share/lab-links
sudo mkdir -p /opt/course/audit
sudo chmod -R 777 /opt/course/audit

sudo mkdir -p /etc/alternative
sudo mkdir -p /opt/target

sudo ln -sf /etc/alternative/editor /usr/share/lab-links/link1
sudo ln -sf /var/log /usr/share/lab-links/link2
sudo ln -sf /opt/target/system /usr/share/lab-links/link3
sudo ln -sf /etc/hosts /usr/share/lab-links/link4
