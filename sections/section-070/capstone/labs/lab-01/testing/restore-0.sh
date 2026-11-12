#!/usr/bin/env bash
set -euo pipefail
pid=$(systemctl show data-ingest-job -p MainPID --value)
sudo sed -i "s/^pid:.*/pid: $pid/" /opt/course/audit/io-report.txt
