# Question

Solve this question on: `terminal`

An extra 2GB disk (`/dev/disk/by-id/virtio-lab013-corrupt`) contains a corrupted ext4 filesystem that cannot be mounted cleanly.

1. Repair the corrupted filesystem using the appropriate offline repair utility.
2. Assign the volume label `RECOVERED_VOL` to the repaired filesystem.
3. Retrieve the unique UUID of this filesystem.
4. Add an entry to `/etc/fstab` to persistently mount this filesystem at `/mnt/recovered` using its **UUID**.
5. Create the mount directory `/mnt/recovered` and mount the filesystem using the persistent configuration.
