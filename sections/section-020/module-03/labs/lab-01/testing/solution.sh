#!/usr/bin/env bash
set -euo pipefail
sudo iscsiadm -m discovery -t sendtargets -p 10.10.60.10
sudo iscsiadm -m node -T iqn.2026-01.io.astrona:storage.cargo -p 10.10.60.10 --login
sudo udevadm settle
for i in $(seq 1 30); do
 disk=$(find /dev/disk/by-path -name '*iscsi-iqn.2026-01.io.astrona:storage.cargo-lun-1' | head -1)
 test -n "$disk" && break
 sleep 1
done
test -b "$disk"
sudo mkfs.ext4 "$disk"
sudo iscsiadm -m node -T iqn.2026-01.io.astrona:storage.cargo -p 10.10.60.10 --op update -n node.startup -v automatic
uuid=$(sudo blkid -s UUID -o value "$disk")
test -n "$uuid"
printf 'UUID=%s /mnt/cargo ext4 defaults,_netdev,nofail 0 2\n' "$uuid" | sudo tee -a /etc/fstab
sudo mkdir -p /mnt/cargo
sudo systemctl daemon-reload
sudo mount /mnt/cargo
