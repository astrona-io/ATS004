#!/usr/bin/env bash
set -eu

sudo sysctl -w net.ipv4.ip_forward=0
sudo sed -i 's/^\s*net.ipv4.ip_forward\s*=.*/net.ipv4.ip_forward = 0/' /etc/sysctl.conf
