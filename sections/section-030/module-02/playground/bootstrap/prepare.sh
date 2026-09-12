#!/usr/bin/env bash
# OS prep for the "Advanced LVM Operations" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
#
# Builds a realistic starting state:
#   - company_storage spans /dev/vdb + /dev/vdc
#   - LV shared_documents (400M ext4) with all extents forced onto /dev/vdb, mounted at
#     /mnt/shared_documents with a sample file
#   - /dev/vdd left raw as the healthy replacement disk
# So pvmove, vgreduce, pvremove, and lvextend all have something real to act on.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

A=/dev/disk/by-id/virtio-s30m02-a   # becomes /dev/vdb — the "failing" disk
B=/dev/disk/by-id/virtio-s30m02-b   # becomes /dev/vdc
C=/dev/disk/by-id/virtio-s30m02-c   # becomes /dev/vdd — raw spare

for _ in $(seq 1 30); do
  [ -e "$A" ] && [ -e "$B" ] && [ -e "$C" ] && break
  sleep 1
done
sudo udevadm settle --timeout=30 || true

# Clean slate on all three, in case of a re-run.
sudo umount /mnt/shared_documents 2>/dev/null || true
sudo vgchange -an company_storage 2>/dev/null || true
sudo vgremove -f company_storage 2>/dev/null || true
for d in "$A" "$B" "$C"; do
  sudo pvremove -ff -y "$d" 2>/dev/null || true
  sudo wipefs -a "$d" || true
  sudo dd if=/dev/zero of="$d" bs=1M count=8 conv=fsync || true
done

sudo pvcreate "$A" "$B"
sudo vgcreate company_storage "$A" "$B"
# Force every extent of shared_documents onto disk A so pvmove has a full disk to evacuate.
sudo lvcreate -n shared_documents -L 400M company_storage "$A"
sudo mkfs.ext4 /dev/company_storage/shared_documents
sudo mkdir -p /mnt/shared_documents
sudo mount /dev/company_storage/shared_documents /mnt/shared_documents
echo "important production data" | sudo tee /mnt/shared_documents/data.txt >/dev/null
sudo mkdir -p /mnt/shared_documents/archive
echo "more production data" | sudo tee /mnt/shared_documents/archive/old.txt >/dev/null

# Record the kernel names so the docs/checkpoints do not have to guess the
# vdb/vdc/vdd ordering.
{
  echo "source_disk=$(readlink -f "$A")   # holds all of shared_documents's extents (the 'failing' disk)"
  echo "second_disk=$(readlink -f "$B")   # also in company_storage"
  echo "spare_disk=$(readlink -f "$C")    # raw, not yet a PV"
} | sudo tee /etc/playground-disks >/dev/null

echo "[playground] ready — see /etc/playground-disks for the kernel disk names:"
cat /etc/playground-disks
