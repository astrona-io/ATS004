#!/usr/bin/env bash
set -euo pipefail
sudo lvextend -L +400M /dev/vg_xfs/lv_xfs

sudo xfs_growfs /mnt/lvm-xfs

df -h /mnt/lvm-xfs
cat /mnt/lvm-xfs/*.txt
