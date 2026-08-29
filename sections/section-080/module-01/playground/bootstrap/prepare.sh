#!/usr/bin/env bash
# OS prep for the "Directory Capacity Auditing" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
# Mounts a second filesystem at /data (so `du -x` has a boundary to stop at)
# and seeds a few files that make `du` output interesting: a large real file,
# a large sparse file, and some data under /opt.
set -euo pipefail

DEV=/dev/disk/by-id/virtio-s80m01-data
for _ in $(seq 1 30); do [ -e "$DEV" ] && break; sleep 1; done
sudo udevadm settle --timeout=30 || true

if [ -e "$DEV" ]; then
  blkid "$DEV" >/dev/null 2>&1 || sudo mkfs.ext4 -q -L DATA "$DEV"
  sudo mkdir -p /data
  grep -q ' /data ' /proc/mounts || sudo mount "$DEV" /data
  sudo chmod 777 /data
  # Put something sizeable on the SECOND filesystem so `du` without -x would
  # wander into it.
  sudo dd if=/dev/zero of=/data/on-other-fs.bin bs=1M count=400 status=none
else
  echo "[playground] WARNING: $DEV did not appear; /data will be missing."
fi

# Large real file on the ROOT filesystem: 256 MiB of actual blocks.
sudo mkdir -p /opt/reports
sudo dd if=/dev/zero of=/opt/reports/big-real.bin bs=1M count=256 status=none

# Sparse file: apparent size 512 MiB, almost no blocks used on disk.
sudo mkdir -p /opt/archive
sudo truncate -s 512M /opt/archive/sparse.img

# A directory tree with many small files.
sudo mkdir -p /opt/logs
for i in $(seq 1 200); do
  printf 'log entry %s\n' "$i" | sudo tee "/opt/logs/app-$i.log" >/dev/null
done

echo "[playground] ready:"
echo "  /data          -> second ext4 filesystem (du -x should stop here)"
echo "  /opt/reports   -> big-real.bin, 256 MiB of real blocks"
echo "  /opt/archive   -> sparse.img, 512 MiB apparent, ~0 on disk"
echo "  /opt/logs      -> 200 tiny files"
