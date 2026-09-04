#!/usr/bin/env bash
# OS prep for the "On-Demand Mounting Fundamentals" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
# Installs autofs, seeds a local directory the chapter bind-mounts through
# autofs, and keeps a pristine /etc/auto.master for easy rollback.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# A local directory with content, used as the bind-mount source in the map.
sudo mkdir -p /srv/localdata
echo "hello from the on-demand bind mount" | sudo tee /srv/localdata/hello.txt >/dev/null
echo "second file" | sudo tee /srv/localdata/notes.txt >/dev/null

# Pristine copy of the master map so edits roll back with one cp.
[ -e /etc/auto.master.orig ] || sudo cp /etc/auto.master /etc/auto.master.orig

# Make sure the trigger directory used by the chapter does NOT exist yet:
# autofs only fires on a path that is not already present.
sudo rmdir /mnt/auto 2>/dev/null || true

echo "[playground] /srv/localdata seeded. /etc/auto.master backed up to /etc/auto.master.orig."
systemctl is-active autofs || echo "(autofs not started yet — the chapter enables it)"
