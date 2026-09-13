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

# Install an on-demand 'catchup' command so a reader who already knows an
# earlier part's material can jump straight to a later part's starting
# state instead of retyping commands they've already practiced, and so
# anyone can reset back to this playground's baseline without a full
# astrona destroy + run cycle. Written here (not as a sibling bootstrap
# file) because only this single script is guaranteed to be copied onto
# the VM by the playground's bootstrap step.
sudo tee /usr/local/bin/catchup > /dev/null <<'CATCHUP_EOF'
#!/usr/bin/env bash
set -euo pipefail
. /etc/playground-disks

usage() {
  cat <<'EOF'
catchup — jump to a later part's starting state in this playground, or
reset back to the beginning.

Usage: catchup <target>

Targets:
  part3   Run Part 2's exercise (vgextend the spare, pvmove the failing
          disk empty) so you land exactly where Part 3 ("Removing the
          emptied disk") begins: company_storage spans 3 PVs, source_disk
          has zero extents left on it.

  part4   Run Part 2 AND Part 3's exercises (part3, above, plus retiring
          source_disk with vgreduce/pvremove, then growing shared_documents
          by 200M and shrinking it back to 350M) so you land exactly where
          Part 4 begins: company_storage has 2 PVs (second_disk,
          spare_disk), shared_documents is 350M, source_disk is raw and
          unclaimed again.

  reset   Re-run this playground's own boot setup: rebuilds the original
          2-PV, 400M starting state from scratch, as if the VM had just
          booted. Use this if you've broken something and don't want to
          destroy and re-run the whole environment.

Only use part3/part4 if you already understand the parts being skipped —
they run the real commands for you, they don't explain them. Read those
parts' course pages first if anything here is unfamiliar.
EOF
}

run_part3() {
  echo "[catchup] Running Part 2's exercise: extend the VG onto the spare, then evacuate source_disk..."
  sudo pvcreate "$spare_disk"
  sudo vgextend company_storage "$spare_disk"
  sudo pvmove "$source_disk"
  echo "[catchup] Done. company_storage spans 3 PVs; source_disk has zero extents left on it."
}

run_part4_rest() {
  echo "[catchup] Running Part 3's exercise: retire source_disk, then grow and shrink shared_documents..."
  sudo vgreduce company_storage "$source_disk"
  sudo pvremove "$source_disk"
  sudo lvextend -L +200M /dev/company_storage/shared_documents
  sudo resize2fs /dev/company_storage/shared_documents
  sudo umount /mnt/shared_documents
  sudo e2fsck -f /dev/company_storage/shared_documents
  sudo resize2fs /dev/company_storage/shared_documents 350M
  sudo lvreduce -L 350M /dev/company_storage/shared_documents
  sudo mount /dev/company_storage/shared_documents /mnt/shared_documents
  echo "[catchup] Done. company_storage has 2 PVs (second_disk, spare_disk); shared_documents is 350M; source_disk is raw and unclaimed."
}

case "${1:-}" in
  part3)
    run_part3
    echo "[catchup] Continue from 'Removing the emptied disk' in Part 3."
    ;;
  part4)
    run_part3
    run_part4_rest
    echo "[catchup] Continue from 'Try it — build a three-way spread' in Part 4."
    ;;
  reset)
    echo "[catchup] Re-running this playground's own boot setup..."
    sudo /usr/local/bin/playground-prepare
    ;;
  *)
    usage
    exit 1
    ;;
esac
CATCHUP_EOF
sudo chmod +x /usr/local/bin/catchup

# Keep a copy of this whole script on the VM under a stable name so
# 'catchup reset' can re-run it later without needing the original
# bootstrap source around.
sudo cp "$0" /usr/local/bin/playground-prepare
sudo chmod +x /usr/local/bin/playground-prepare

echo "[playground] already know Part 2 or Part 2+3 and want to skip ahead? Run: catchup part3   or   catchup part4"
echo "[playground] broke something and want to start over without destroying the VM? Run: catchup reset"
