#!/usr/bin/env bash
set -euo pipefail
sudo mkdir -p /opt/course/audit
device=$(findmnt -n -o SOURCE /mnt/data-ingest)
pid=$(systemctl show data-ingest-job -p MainPID --value)
test "$pid" -gt 1
printf 'device: %s
pid: %s
process: data-ingest-job
direction: write
mountpoint: /mnt/data-ingest
' "$device" "$pid" | sudo tee /opt/course/audit/io-report.txt
