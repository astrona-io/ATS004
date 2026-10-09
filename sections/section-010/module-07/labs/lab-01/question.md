# Question

Solve this question on: `terminal`

Astronaut, a crew member needs a drive that every ship in the galaxy can read. An extra 1 GB disk, `/dev/disk/by-id/virtio-lab017-media`, plays the part of a blank USB flash drive. Turn it into a removable drive that your own user can write to.

1. Format the disk as a **FAT32** filesystem (not FAT16) with the volume label `USBDATA`.
2. Create the mount point `/mnt/usbdata`.
3. Mount the filesystem at `/mnt/usbdata` so that files on it appear owned by your own user (`ubuntu`), not `root`, and you can write to them without `sudo`.
4. Prove it works: as your normal user (no `sudo`), create a file at `/mnt/usbdata/proof.txt`.

The grader checks the live machine: the filesystem type and label on the disk, what is mounted at `/mnt/usbdata` and with which `uid=`, and who owns and can write `proof.txt`.
