#!/usr/bin/env bash
# Bootstrap: an ext4 spool disk mounted at /mnt/spool. One background process
# writes a 300M file there, deletes it, and keeps it open -- the space stays
# used but no name shows it. The PID is saved in /var/lib/lab070202-holder.pid
# for the grader only. Finding the holder and the scheduler rule are the graded tasks.
set -eu

DEV=/dev/disk/by-id/virtio-lab070202-spool
for _ in $(seq 1 30); do
  [ -e "$DEV" ] && break
  sleep 1
done
sudo udevadm settle --timeout=30 || true

sudo mkfs.ext4 -q -L SPOOL "$DEV"
sudo mkdir -p /mnt/spool
sudo mount "$DEV" /mnt/spool
sudo chmod 1777 /mnt/spool
echo "spool is in use" | sudo tee /mnt/spool/README.txt > /dev/null

sudo rm -f /var/lib/lab070202-holder.pid
sudo setsid nohup bash -c '
  exec 9>/mnt/spool/old-export.dat
  head -c 300M /dev/zero >&9
  rm -f /mnt/spool/old-export.dat
  echo $$ > /var/lib/lab070202-holder.pid
  exec sleep infinity
' >/dev/null 2>&1 &

for _ in $(seq 1 60); do
  [ -s /var/lib/lab070202-holder.pid ] && break
  sleep 1
done
sync
