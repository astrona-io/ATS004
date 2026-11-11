#!/usr/bin/env bash
set -euo pipefail
sudo sed -i 's/^pid:.*/pid: 1/' /opt/course/audit/io-report.txt
