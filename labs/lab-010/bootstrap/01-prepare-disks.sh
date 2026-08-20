#!/usr/bin/env bash
# Bootstrap: formats and fills the "backup-blue"/"backup-red" extraDisks so
# the "which disk has higher usage" step of the task has a real, verifiable
# answer. The "scratch" extraDisk is deliberately left raw/unformatted --
# that's the student's job.
#
# IMPORTANT: astrona-cli's extraDisks are NOT guaranteed to land on
# /dev/vdb/vdc/vdd -- in practice they can enumerate BEFORE the main disk,
# so a raw device-letter guess here risks formatting the VM's own root
# filesystem. Every disk this script touches is resolved via its `serial`
# (set in config.yaml) through the kernel's stable
# /dev/disk/by-id/virtio-<serial> path instead.

set -eu

BLUE=/dev/disk/by-id/virtio-lab010-blue
RED=/dev/disk/by-id/virtio-lab010-red

for dev in "$BLUE" "$RED"; do
  for i in $(seq 1 30); do
    [ -e "$dev" ] && break
    sleep 1
  done
done

# by-id symlinks existing doesn't mean udev is fully done with the
# underlying device -- blkid/lvm probing a freshly attached virtio-blk
# device can still hold it open briefly, which makes mke2fs's busy-check
# (EXT2_MF_BUSY, not overridable by -F) fail with "apparently in use by
# the system". Settle udev and retry mkfs a few times to absorb that race.
sudo udevadm settle --timeout=30 || true

mkfs_retry() {
  local dev="$1"
  for i in $(seq 1 10); do
    if sudo mkfs.ext4 -F "$dev"; then
      return 0
    fi
    echo "mkfs.ext4 on $dev busy, retrying ($i/10)..." >&2
    sudo udevadm settle --timeout=5 || true
    sleep 2
  done
  echo "mkfs.ext4 on $dev failed after retries" >&2
  return 1
}

# backup-blue, filled to ~70% used (the busier disk)
mkfs_retry "$BLUE"
sudo mkdir -p /mnt/backup-blue
sudo mount "$BLUE" /mnt/backup-blue
sudo dd if=/dev/urandom of=/mnt/backup-blue/filler bs=1M count=1950 status=none
sudo mkdir -p /mnt/backup-blue/.trash
sudo dd if=/dev/urandom of=/mnt/backup-blue/.trash/old-log-1 bs=1M count=5 status=none
sudo dd if=/dev/urandom of=/mnt/backup-blue/.trash/old-log-2 bs=1M count=5 status=none

# backup-red, filled to ~33% used (the less busy disk). This is also where
# dark-matter-v2's executable lives -- see 02-dark-matter-processes.sh.
mkfs_retry "$RED"
sudo mkdir -p /mnt/backup-red
sudo mount "$RED" /mnt/backup-red
sudo dd if=/dev/urandom of=/mnt/backup-red/filler bs=1M count=900 status=none
sudo mkdir -p /mnt/backup-red/.trash
sudo dd if=/dev/urandom of=/mnt/backup-red/.trash/old-log-1 bs=1M count=3 status=none
