#!/usr/bin/env bash
set -eu

if ! command -v iostat >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y sysstat
fi

DISK2=/dev/disk/by-id/virtio-lab071-disk2

for i in $(seq 1 30); do
  [ -e "$DISK2" ] && break
  sleep 1
done

sudo udevadm settle --timeout=30 || true

sudo mkfs.ext4 -F "$DISK2"
sudo mkdir -p /mnt/slow-disk
sudo mount "$DISK2" /mnt/slow-disk

sudo mkdir -p /opt/course/audit
sudo chmod -R 777 /opt/course/audit

sudo tee /opt/saturator.sh > /dev/null <<'EOF'
#!/usr/bin/env bash
while true; do
  dd if=/dev/urandom of=/mnt/slow-disk/test-file bs=1M count=50 oflag=sync status=none
  sleep 0.1
done
EOF

sudo chmod +x /opt/saturator.sh
nohup /opt/saturator.sh >/dev/null 2>&1 &
