#!/usr/bin/env bash
set -euo pipefail
sudo -u carol dd if=/dev/zero of=/quota2/carol/bigfile bs=1M count=30 status=none
sudo setquota -t 120 120 /quota2
set +e
sudo -u carol dd if=/dev/zero of=/quota2/carol/overfile bs=1M count=22 status=none
rc=$?
set -e
test "$rc" -ne 0
sudo repquota -s /quota2 | sudo tee /root/grace-evidence.txt
