#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Prepares the raw disk block state for lab-014
set -eu
echo "Ready for local storage creation lab."
exit 0
ASTRONA_STUDENT_SCRIPT
