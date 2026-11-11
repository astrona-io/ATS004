#!/usr/bin/env bash
set -euo pipefail
. /etc/lab034-raid
sudo mdadm --manage /dev/md0 --fail "$member2"
sudo mdadm --manage /dev/md0 --remove "$member2"
sudo mdadm --manage /dev/md0 --add "$spare"
sudo mdadm --wait /dev/md0
