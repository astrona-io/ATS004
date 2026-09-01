#!/usr/bin/env bash
# Bootstrap: creates the report destination directory, then formats and
# mounts the extra disk with a large dummy file so the "don't fold a
# separately mounted filesystem into /" requirement has a real mount to
# trip up a du scan that forgets -x.
#
# IMPORTANT: astrona-cli's extraDisks are NOT guaranteed to land on
# /dev/vdb -- in practice they can enumerate BEFORE the main disk, so a
# raw device-letter guess here risks formatting the VM's own root
# filesystem. This disk is resolved via its `serial` (set in config.yaml)
# through the kernel's stable /dev/disk/by-id/virtio-<serial> path instead.

set -eu

sudo mkdir -p /opt/course/audit

BIGSHARE=/dev/disk/by-id/virtio-lab080-bigshare

for i in $(seq 1 30); do
  [ -e "$BIGSHARE" ] && break
  sleep 1
done

# by-id symlink existing doesn't mean udev is fully done with the
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

mkfs_retry "$BIGSHARE"
sudo mkdir -p /mnt/bigshare
sudo mount "$BIGSHARE" /mnt/bigshare

if command -v fallocate >/dev/null 2>&1; then
  sudo fallocate -l 1G /mnt/bigshare/dataset.bin
else
  sudo dd if=/dev/zero of=/mnt/bigshare/dataset.bin bs=1M count=1024
fi
