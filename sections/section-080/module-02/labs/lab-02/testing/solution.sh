#!/usr/bin/env bash
set -euo pipefail
set +e
sudo -u carol dd if=/dev/zero of=/quota2/carol/bigfile bs=1M count=30 status=none
rc=$?
set -e
test "$rc" -ne 0
sudo -u carol rm /quota2/carol/bigfile
sudo setquota -t 120 120 /quota2
sudo -u carol dd if=/dev/zero of=/quota2/carol/overfile bs=1M count=22 status=none
sync
sudo repquota -s /quota2 | sudo tee /root/grace-evidence.txt
