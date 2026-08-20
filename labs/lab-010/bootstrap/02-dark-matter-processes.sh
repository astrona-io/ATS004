#!/usr/bin/env bash
# Bootstrap: creates two long-running "processes" (dark-matter-v1 and
# dark-matter-v2) with a deliberate, deterministic memory gap so the
# RSS/VSZ comparison step has one clear winner, and with a real,
# resolvable /proc/<PID>/exe target so Step 8/9 of the solution work.
#
# The trick: /proc/<PID>/exe and `ps -o comm` both key off the *binary
# path actually passed to execve*, not off argv or a shebang target. So
# instead of running these as `#!/usr/bin/env python3` scripts (which
# would make /proc/<PID>/exe resolve to the python3 interpreter, not to
# our script), each service execs a *copy* of the python3 binary that has
# been renamed to dark-matter-v1 / dark-matter-v2 and lives at the exact
# path the scenario expects -- with the actual Python source passed as a
# separate script argument. That copy IS the executed binary, so both
# `comm` and /proc/<PID>/exe come out correct automatically.
#
# dark-matter-v2's binary lives on /mnt/backup-red -- this must run after
# 01-prepare-disks.sh has formatted and mounted that disk.
#
# Deliberately no Restart=always: the task ends with unmounting the disk
# that holds the winning process's executable, which requires the process
# to actually stay dead once stopped/killed. A restarting service would
# immediately reopen the executable and make the disk permanently busy.

set -eu

if ! command -v python3 >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y python3
fi

PYTHON3_BIN="$(command -v python3)"

sudo mkdir -p /opt/lab-scripts

# --- dark-matter-v1: smaller memory footprint, lives on the root filesystem ---

sudo tee /opt/lab-scripts/dark-matter-v1.py > /dev/null <<'EOF'
import time
_buf = bytearray(50 * 1024 * 1024)  # ~50MB resident
time.sleep(10 ** 8)
EOF

sudo mkdir -p /usr/local/bin
sudo cp "$PYTHON3_BIN" /usr/local/bin/dark-matter-v1
sudo chmod +x /usr/local/bin/dark-matter-v1

sudo tee /etc/systemd/system/dark-matter-v1.service > /dev/null <<'EOF'
[Unit]
Description=dark-matter-v1 lab workload
After=network.target

[Service]
ExecStart=/usr/local/bin/dark-matter-v1 /opt/lab-scripts/dark-matter-v1.py
User=nobody

[Install]
WantedBy=multi-user.target
EOF

# --- dark-matter-v2: larger memory footprint, binary on /mnt/backup-red ---
# (this is the disk the task ultimately wants unmounted)

sudo tee /opt/lab-scripts/dark-matter-v2.py > /dev/null <<'EOF'
import time
_buf = bytearray(300 * 1024 * 1024)  # ~300MB resident
time.sleep(10 ** 8)
EOF

sudo mkdir -p /mnt/backup-red/bin
sudo cp "$PYTHON3_BIN" /mnt/backup-red/bin/dark-matter-v2
sudo chmod +x /mnt/backup-red/bin/dark-matter-v2

sudo tee /etc/systemd/system/dark-matter-v2.service > /dev/null <<'EOF'
[Unit]
Description=dark-matter-v2 lab workload
After=network.target

[Service]
ExecStart=/mnt/backup-red/bin/dark-matter-v2 /opt/lab-scripts/dark-matter-v2.py
User=nobody

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now dark-matter-v1.service
sudo systemctl enable --now dark-matter-v2.service
