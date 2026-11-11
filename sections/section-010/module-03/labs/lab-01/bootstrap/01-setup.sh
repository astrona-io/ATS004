#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -eu
sudo udevadm settle --timeout=30 || true
ASTRONA_STUDENT_SCRIPT
