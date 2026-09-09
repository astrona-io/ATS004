# Question

Solve this question on: `terminal`

Build a redundant storage array from three raw disks using Linux software RAID.

1. Locate the three raw 1GB secondary disks on the system.
2. Create a RAID 5 array named `/dev/md0` from all three disks.
3. Format `/dev/md0` with the `ext4` filesystem.
4. Mount the array at `/mnt/raid-data`.
5. Make the array persistent: record it in `/etc/mdadm/mdadm.conf` and refresh the initramfs.
6. Add a persistent `/etc/fstab` entry for `/mnt/raid-data`, keyed by the filesystem's `UUID=`, with the `nofail` option.
