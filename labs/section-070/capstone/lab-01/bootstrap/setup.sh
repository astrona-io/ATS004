#!/usr/bin/env bash
# Bootstrap: installs sysstat (vmstat/iostat) and iotop, formats the extra
# scratch disk and mounts it at /mnt/data-ingest, then starts a continuous
# write-heavy background job against it so the lab's I/O bottleneck is real
# and reproducible via vmstat/iostat/iotop, not simulated text. /opt/course/
# audit is created for the student's io-report.txt deliverable, left
# otherwise empty.
#
# IMPORTANT: astrona-cli's extraDisks are NOT guaranteed to land on
# /dev/vdb -- in practice a single extraDisk can enumerate BEFORE the main
# disk, so a raw device-letter guess here risks formatting the VM's own
# root filesystem. This disk is resolved via its `serial` (set in
# config.yaml) through the kernel's stable /dev/disk/by-id/virtio-<serial>
# path instead.

set -eu

if ! command -v iostat >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y sysstat
fi

if ! command -v iotop >/dev/null 2>&1; then
  sudo apt-get install -y iotop
fi

DISK=/dev/disk/by-id/virtio-lab070-ingest
for i in $(seq 1 30); do
  [ -e "$DISK" ] && break
  sleep 1
done

# by-id symlink existing doesn't mean udev is fully done with the
# underlying device -- blkid/lvm probing a freshly attached virtio-blk
# device can still hold it open briefly, which makes mke2fs's busy-check
# (EXT2_MF_BUSY, not overridable by -F) fail with "apparently in use by
# the system". Settle udev and retry mkfs a few times to absorb that race.
sudo udevadm settle --timeout=30 || true

if ! blkid "$DISK" >/dev/null 2>&1; then
  mkfs_ok=0
  for i in $(seq 1 10); do
    if sudo mkfs.ext4 -F "$DISK"; then
      mkfs_ok=1
      break
    fi
    echo "mkfs.ext4 on $DISK busy, retrying ($i/10)..." >&2
    sudo udevadm settle --timeout=5 || true
    sleep 2
  done
  [ "$mkfs_ok" -eq 1 ] || { echo "mkfs.ext4 on $DISK failed after retries" >&2; exit 1; }
fi

sudo mkdir -p /mnt/data-ingest
if ! mountpoint -q /mnt/data-ingest; then
  sudo mount "$DISK" /mnt/data-ingest
fi
grep -q "^$DISK /mnt/data-ingest" /etc/fstab 2>/dev/null || \
  echo "$DISK /mnt/data-ingest ext4 defaults 0 2" | sudo tee -a /etc/fstab > /dev/null

sudo mkdir -p /opt/course/audit

# The load-generating process: name it literally "data-ingest-job" so its
# comm/process name is exactly what the scenario's iotop step should find.
sudo tee /usr/local/bin/data-ingest-job > /dev/null <<'EOF'
#!/usr/bin/env bash
# Continuous moderate write load against /mnt/data-ingest — the write-bound
# I/O bottleneck this lab asks the student to diagnose.
set -eu
while true; do
  dd if=/dev/zero of=/mnt/data-ingest/churn bs=1M count=64 conv=fsync 2>/dev/null
  sleep 0.2
done
EOF
sudo chmod +x /usr/local/bin/data-ingest-job

sudo tee /etc/systemd/system/data-ingest-job.service > /dev/null <<'EOF'
[Unit]
Description=Simulated data-ingest write load (lab-070 I/O bottleneck)
After=mnt-data\x2dingest.mount

[Service]
ExecStart=/usr/local/bin/data-ingest-job
Restart=always
Nice=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now data-ingest-job.service
