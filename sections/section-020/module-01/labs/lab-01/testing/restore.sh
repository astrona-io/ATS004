#!/usr/bin/env bash
set -euo pipefail
sudo mkdir -p /mnt/sshfs-share
sudo sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf
printf '%s
' password123 | sudo sshfs -o password_stdin,allow_other,StrictHostKeyChecking=accept-new sshuser@127.0.0.1:/opt/remote-data /mnt/sshfs-share
