#!/usr/bin/env bash
set -u

SOURCE=$(readlink -f /dev/disk/by-id/virtio-lab018-source)
CLONE=$(readlink -f /dev/disk/by-id/virtio-lab018-clone)

if [ -z "$SOURCE" ] || [ -z "$CLONE" ]; then
  echo "FAIL: could not resolve source/clone disk device names"
  exit 1
fi

if ! sudo cmp -s "$SOURCE" "$CLONE"; then
  echo "FAIL: $CLONE is not a byte-for-byte match of $SOURCE"
  exit 1
fi

# Belt-and-suspenders: confirm the clone actually carries a working,
# mountable copy of the source's filesystem and file content, not just
# that the raw bytes happen to compare equal.
LABEL=$(sudo blkid -s LABEL -o value "$CLONE" 2>/dev/null || true)
if [ "$LABEL" != "SOURCEVOL" ]; then
  echo "FAIL: clone disk label is '$LABEL', expected 'SOURCEVOL'"
  exit 1
fi

sudo mkdir -p /mnt/lab018-verify
sudo mount -o ro "$CLONE" /mnt/lab018-verify

content=$(cat /mnt/lab018-verify/hello.txt 2>/dev/null || true)
sudo umount /mnt/lab018-verify

if [ "$content" != "sample data for lab018 dd clone" ]; then
  echo "FAIL: clone's hello.txt content does not match the source ('$content')"
  exit 1
fi

echo "PASS: clone disk is a verified byte-for-byte match of the source disk"
exit 0
