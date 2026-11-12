#!/usr/bin/env bash
set -eu
sudo umount /mnt/appdata
sudo mount -t tmpfs tmpfs /mnt/appdata
