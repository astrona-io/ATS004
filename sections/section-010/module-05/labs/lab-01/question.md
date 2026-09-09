# Question

Solve this question on: `terminal`

A raw secondary disk (`/dev/disk/by-id/virtio-lab015-data1`) is attached but has no filesystem and is not mounted.

1. Format the disk `ext4` with the volume label `APPDATA`.
2. Create the mount point `/mnt/appdata`.
3. Add a persistent entry to `/etc/fstab` for this filesystem, keyed by its **`UUID=`** (not a `/dev/` path), with mount options `defaults,nofail,noatime`, `dump` set to `0`, and `pass` set to `2`.
4. Apply the new entry with `mount -a` and confirm it is mounted.
5. Verify the entry is safe with `findmnt --verify` before you would trust it at boot.
