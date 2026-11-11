#!/usr/bin/env bash
set -euo pipefail
sudo lvextend -L +200M /dev/vg_resize/lv_data
sudo resize2fs /dev/vg_resize/lv_data
sudo umount /mnt/resize-data
sudo e2fsck -f -p /dev/vg_resize/lv_data
sudo resize2fs /dev/vg_resize/lv_data 350M
sudo lvreduce -y -L 350M /dev/vg_resize/lv_data
sudo mount /dev/vg_resize/lv_data /mnt/resize-data
