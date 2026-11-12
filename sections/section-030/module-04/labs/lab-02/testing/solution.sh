#!/usr/bin/env bash
set -euo pipefail
. /etc/lab036-raid
sudo mdadm --manage /dev/md0 --add "$spare"
# mdadm returns 1 if no resync needed waiting; verify the resulting state.
sudo mdadm --wait /dev/md0 || test "$(cat /sys/block/md0/md/sync_action)" = idle
sudo mdadm --grow /dev/md0 --raid-devices=4 --backup-file=/root/raid-reshape.backup
# mdadm returns 1 if no resync needed waiting; verify the resulting state.
sudo mdadm --wait /dev/md0 || test "$(cat /sys/block/md0/md/sync_action)" = idle
sudo resize2fs /dev/md0
printf '%s
' 'MAILADDR root@localhost' | sudo tee -a /etc/mdadm/mdadm.conf
sudo mdadm --monitor --scan --oneshot --test
