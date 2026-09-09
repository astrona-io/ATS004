#!/usr/bin/env bash
set -eu

DISK=/dev/disk/by-id/virtio-lab042-swapdisk
for i in $(seq 1 30); do
  [ -e "$DISK" ] && break
  sleep 1
done

sudo udevadm settle --timeout=30 || true

sudo swapoff -a || true

sudo dd if=/dev/zero of=/swapfile bs=1M count=256
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon -p 5 /swapfile

sudo tee /etc/fstab > /dev/null <<'EOF'
# /etc/fstab: static file system information.
/dev/vda1 / ext4 defaults 0 1
/swapfile none swap sw,pri=5 0 0
EOF
