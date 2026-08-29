#!/usr/bin/env bash
# OS prep for the "Process-Level Auditing" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
# Installs iotop/sysstat/lsof/fio, mounts an ext4 fs at /mnt/perf, turns on
# task delay accounting (iotop reports zeros without it on modern kernels),
# and drops a write-load helper on PATH.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

if ! command -v iotop >/dev/null 2>&1 || ! command -v pidstat >/dev/null 2>&1 \
   || ! command -v lsof >/dev/null 2>&1 || ! command -v fio >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y iotop sysstat lsof fio
fi

# iotop needs task delay accounting; it is off by default on kernels >= 5.14.
echo 'kernel.task_delayacct = 1' | sudo tee /etc/sysctl.d/99-delayacct.conf >/dev/null
sudo sysctl --system >/dev/null 2>&1 || true

DEV=/dev/disk/by-id/virtio-s70m02-perf
for _ in $(seq 1 30); do [ -e "$DEV" ] && break; sleep 1; done
sudo udevadm settle --timeout=30 || true
if [ -e "$DEV" ]; then
  blkid "$DEV" >/dev/null 2>&1 || sudo mkfs.ext4 -q -L PERF "$DEV"
  sudo mkdir -p /mnt/perf
  grep -q ' /mnt/perf ' /proc/mounts || sudo mount "$DEV" /mnt/perf
  sudo chmod 777 /mnt/perf
else
  echo "[playground] WARNING: $DEV did not appear."
fi

sudo tee /usr/local/bin/start-io-load >/dev/null <<'EOF'
#!/usr/bin/env bash
# Background a continuous write to a single file on /mnt/perf and print the PID.
# Stop it with: stop-io-load
fio --name=leak --filename=/mnt/perf/leak.log --rw=write --bs=1M --size=512M \
    --time_based --runtime=1800 --direct=1 --eta=never >/tmp/leak.out 2>&1 &
echo "write load started, PID $!  (file: /mnt/perf/leak.log)"
EOF
sudo chmod +x /usr/local/bin/start-io-load

sudo tee /usr/local/bin/stop-io-load >/dev/null <<'EOF'
#!/usr/bin/env bash
pkill -f 'fio --name=leak' && echo "write load stopped." || echo "no write load running."
rm -f /mnt/perf/leak.log
EOF
sudo chmod +x /usr/local/bin/stop-io-load

echo "[playground] ready. 'start-io-load' backgrounds a writer to /mnt/perf/leak.log; 'stop-io-load' ends it."
