#!/usr/bin/env bash
set -eu
sudo mount -o remount,strictatime /dev/disk/by-id/virtio-lab015-data1 /mnt/appdata
findmnt -no OPTIONS /mnt/appdata
