#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -eu
sudo mkdir -p /opt/course/audit
sudo chmod -R 777 /opt/course/audit
ASTRONA_STUDENT_SCRIPT
