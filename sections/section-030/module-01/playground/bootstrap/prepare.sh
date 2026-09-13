#!/usr/bin/env bash
# OS prep for the "LVM Fundamentals" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
# Makes sure lvm2 is installed and the three spare disks carry no LVM
# metadata or filesystem signatures, so pvcreate/vgcreate start from nothing.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

DISKS=(
  /dev/disk/by-id/virtio-s30m01-a
  /dev/disk/by-id/virtio-s30m01-b
  /dev/disk/by-id/virtio-s30m01-c
)

for _ in $(seq 1 30); do
  missing=0
  for d in "${DISKS[@]}"; do [ -e "$d" ] || missing=1; done
  [ "$missing" -eq 0 ] && break
  sleep 1
done
sudo udevadm settle --timeout=30 || true

for d in "${DISKS[@]}"; do
  if [ -e "$d" ]; then
    sudo wipefs -a "$d" || true
    sudo dd if=/dev/zero of="$d" bs=1M count=8 conv=fsync || true
  else
    echo "[playground] WARNING: $d did not appear."
  fi
done

# Install an on-demand 'catchup' command so a reader who already knows an
# earlier part's material (or is picking this back up after a break) can
# jump straight to a later part's starting state instead of retyping
# commands they've already practiced. Written here (not as a sibling
# bootstrap file) because only this single script is guaranteed to be
# copied onto the VM by the playground's bootstrap step.
sudo tee /usr/local/bin/catchup > /dev/null <<'CATCHUP_EOF'
#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
catchup — jump to a later part's starting state in this playground.

Usage: catchup <target>

Targets:
  part3   Run Part 2's exercise (pvcreate + vgcreate) so you land exactly
          where Part 3 ("Carving out a logical volume") begins: a Volume
          Group named company_storage pooling /dev/vdc and /dev/vdd,
          nothing carved out of it yet.

Only use this if you already understand the part being skipped — it runs
the real commands for you, it doesn't explain them. Read that part's
course page first if anything here is unfamiliar.
EOF
}

case "${1:-}" in
  part3)
    echo "[catchup] Running Part 2's exercise: initialise two disks as PVs and pool them into a VG..."
    sudo pvcreate /dev/vdc /dev/vdd
    sudo vgcreate company_storage /dev/vdc /dev/vdd
    echo "[catchup] Done. company_storage now pools /dev/vdc and /dev/vdd, empty."
    echo "[catchup] Continue from 'Carving out a logical volume' in Part 3."
    ;;
  *)
    usage
    exit 1
    ;;
esac
CATCHUP_EOF
sudo chmod +x /usr/local/bin/catchup

echo "[playground] ready. Spare disks are commonly /dev/vdb /dev/vdc /dev/vdd — confirm with 'lsblk'."
echo "[playground] already done Part 2's exercise elsewhere and want to skip to Part 3? Run: catchup part3"
