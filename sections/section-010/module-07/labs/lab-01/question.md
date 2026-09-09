# Question

Solve this question on: `terminal`

An extra 1GB disk (`/dev/disk/by-id/virtio-lab017-media`) simulates a blank USB flash drive.

1. Format the disk as a **FAT32** filesystem (not FAT16) with the volume label `USBDATA`.
2. Create the mount point `/mnt/usbdata`.
3. Mount the filesystem at `/mnt/usbdata` so that files on it appear owned by your own user (`ubuntu`) rather than `root`, and are writable by you without `sudo`.
4. Prove it works: as your normal user (no `sudo`), create a file at `/mnt/usbdata/proof.txt`.
