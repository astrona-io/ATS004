#!/usr/bin/env bash
set -euo pipefail
. /etc/lab036-raid
sudo mdadm --manage /dev/md0 --add "$spare"
sudo mdadm --grow /dev/md0 --raid-devices=4
sudo mdadm --wait /dev/md0
sudo resize2fs /dev/md0
printf '%s
' 'MAILADDR root@localhost' | sudo tee -a /etc/mdadm/mdadm.conf
sudo mdadm --monitor --scan --oneshot --test
