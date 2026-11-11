#!/usr/bin/env bash
set -euo pipefail
sudo mkdir -p /opt/course/audit
pid=$(pgrep -f '[r]ogue_writer.py' | head -1)
printf '%s
%s
' "$pid" /var/log/rogue_activity.log | sudo tee /opt/course/audit/culprit.txt
