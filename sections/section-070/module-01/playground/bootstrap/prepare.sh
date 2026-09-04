#!/usr/bin/env bash
# OS prep for the "Device-Level Diagnostics" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
# Installs sysstat + fio, mounts an ext4 filesystem on the spare disk at
# /mnt/perf, and drops an I/O-load helper on PATH.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

DEV=/dev/disk/by-id/virtio-s70m01-perf
for _ in $(seq 1 30); do [ -e "$DEV" ] && break; sleep 1; done
sudo udevadm settle --timeout=30 || true

if [ -e "$DEV" ]; then
  if ! blkid "$DEV" >/dev/null 2>&1; then
    sudo mkfs.ext4 -q -L PERF "$DEV"
  fi
  sudo mkdir -p /mnt/perf
  grep -q ' /mnt/perf ' /proc/mounts || sudo mount "$DEV" /mnt/perf
  sudo chmod 777 /mnt/perf
else
  echo "[playground] WARNING: $DEV did not appear."
fi

sudo tee /usr/local/bin/start-io-load >/dev/null <<'EOF'
#!/usr/bin/env bash
# Generate write load against /mnt/perf. Usage:
#   start-io-load seq    # high-throughput sequential writes (default)
#   start-io-load rand   # high-IOPS small random writes
# Prints the background PID. Stop everything with: stop-io-load
mode="${1:-seq}"
case "$mode" in
  seq)  fio --name=seq --directory=/mnt/perf --rw=write --bs=1M --size=512M \
            --numjobs=1 --time_based --runtime=600 --direct=1 \
            --eta=never --minimal >/tmp/io-load.out 2>&1 & ;;
  rand) fio --name=rand --directory=/mnt/perf --rw=randwrite --bs=4k --size=256M \
            --numjobs=1 --time_based --runtime=600 --direct=1 --iodepth=8 \
            --eta=never --minimal >/tmp/io-load.out 2>&1 & ;;
  *)    echo "usage: start-io-load [seq|rand]"; exit 2 ;;
esac
echo "I/O load ($mode) started, PID $!"
EOF
sudo chmod +x /usr/local/bin/start-io-load

sudo tee /usr/local/bin/stop-io-load >/dev/null <<'EOF'
#!/usr/bin/env bash
pkill -f 'fio --name=' && echo "I/O load stopped." || echo "no I/O load running."
EOF
sudo chmod +x /usr/local/bin/stop-io-load

echo "[playground] ready. /mnt/perf is on the spare disk (commonly /dev/vdb)."
echo "[playground] run 'start-io-load seq' or 'start-io-load rand'; 'stop-io-load' to end."
