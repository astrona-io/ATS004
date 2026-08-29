#!/usr/bin/env bash
# Bootstrap for the "nfs" VM: NFS server for the automount playground.
# Environment prep only — no task, no grading.
set -eu

export DEBIAN_FRONTEND=noninteractive

if ! command -v exportfs >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y nfs-kernel-server
fi
sudo systemctl enable --now nfs-kernel-server

sudo mkdir -p /export/eng /export/mkt
echo "engineering shared file"  | sudo tee /export/eng/eng-readme.txt >/dev/null
echo "marketing shared file"    | sudo tee /export/mkt/mkt-readme.txt >/dev/null
sudo chmod 755 /export /export/eng /export/mkt

cat <<'EOF' | sudo tee /etc/exports >/dev/null
/export/eng  10.10.50.0/24(ro,sync,no_subtree_check)
/export/mkt  10.10.50.0/24(ro,sync,no_subtree_check)
EOF
sudo exportfs -ra

if ! grep -q '[[:space:]]client$' /etc/hosts; then
  echo "10.10.50.5 client" | sudo tee -a /etc/hosts >/dev/null
fi

echo "[playground] nfs ready: /export/eng and /export/mkt exported ro to 10.10.50.0/24."
