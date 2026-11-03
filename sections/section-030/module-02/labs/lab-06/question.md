# Question

Solve this question on: `terminal`

Astronaut, a volume group named `vg_data` lives on the disk `/dev/disk/by-id/virtio-lab030206-disk1`. It holds a logical volume `lv_reports` with an **ext4** filesystem. Someone docked it by hand at `/mnt/reports`, and it holds one file, `reports-marker.txt`. There is no `/etc/fstab` line for it, so it would be gone after the next launch. The volume is also nearly full.

1. Add a line to `/etc/fstab` that docks `lv_reports` at `/mnt/reports` as ext4. Use the filesystem's `UUID=` (find it with `blkid`).
2. Grow `lv_reports` by `300M` **and** its filesystem in one command, with the volume still mounted.
3. Check the file before any restart with `sudo findmnt --verify`, and confirm the new size with `df -h /mnt/reports`.

The grader reads `/etc/fstab`, unmounts `/mnt/reports`, runs `mount -a`, and checks that the volume is about 800M, that the filesystem reports the bigger size, and that `reports-marker.txt` is still there.
