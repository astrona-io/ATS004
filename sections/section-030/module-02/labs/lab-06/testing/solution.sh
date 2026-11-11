#!/usr/bin/env bash
set -euo pipefail
uuid=$(sudo blkid -s UUID -o value /dev/vg_data/lv_reports)
printf 'UUID=%s /mnt/reports ext4 defaults,nofail 0 2
' "$uuid" | sudo tee -a /etc/fstab
sudo lvextend -r -L +300M /dev/vg_data/lv_reports
sudo systemctl daemon-reload
sudo umount /mnt/reports
sudo mount -a
