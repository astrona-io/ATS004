#!/usr/bin/env bash
# Bootstrap: formats and mounts /mnt/locked-vault, then starts a
# long-running process that holds the mount busy -- its working directory
# AND an open file both live inside it, so umount refuses until the
# process is actually found and stopped, not just guessed at.
#
# The trick (same one used by the section-010 capstone lab): exec a
# *copy* of the python3 binary renamed to vault-keeper, with the real
# Python source passed as a separate script argument. That copy is what
# actually gets exec'd, so both `comm` and lsof/fuser show a clearly
# identifiable process name instead of a generic "python3".
#
# Deliberately no Restart=always: the task ends with the process staying
# dead once stopped. A restarting unit would immediately reopen the mount
# and make it permanently busy again.

set -eu

sudo udevadm settle --timeout=30 || true

DISK=/dev/disk/by-id/virtio-lab019-vault
for i in $(seq 1 30); do
  [ -e "$DISK" ] && break
  sleep 1
done

sudo mkfs.ext4 -q "$DISK"
sudo mkdir -p /mnt/locked-vault
sudo mount "$DISK" /mnt/locked-vault
sudo chmod 1777 /mnt/locked-vault
echo "vault data" | sudo tee /mnt/locked-vault/secret.txt > /dev/null

PYTHON3_BIN="$(command -v python3)"
sudo mkdir -p /opt/lab-scripts

sudo tee /opt/lab-scripts/vault-keeper.py > /dev/null <<'EOF'
import time
f = open("/mnt/locked-vault/.lockfile", "w")
f.write("held\n")
f.flush()
while True:
    time.sleep(5)
EOF

sudo cp "$PYTHON3_BIN" /usr/local/bin/vault-keeper
sudo chmod +x /usr/local/bin/vault-keeper

sudo tee /etc/systemd/system/vault-keeper.service > /dev/null <<'EOF'
[Unit]
Description=vault-keeper lab workload (holds /mnt/locked-vault busy)
After=local-fs.target

[Service]
ExecStart=/usr/local/bin/vault-keeper /opt/lab-scripts/vault-keeper.py
WorkingDirectory=/mnt/locked-vault
Restart=no

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now vault-keeper.service
