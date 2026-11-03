# Question

Solve this question on: `terminal`

Astronaut, a cargo hold came back from a rough flight damaged. The extra 2 GB disk `/dev/disk/by-id/virtio-lab013-corrupt` holds an ext4 filesystem that is corrupted and cannot be mounted cleanly. Repair it, give it a name, and make sure it docks at the same hatch after every launch.

1. Repair the corrupted filesystem with the right offline repair tool. The filesystem must not be mounted while you repair it.
2. Give the repaired filesystem the label `RECOVERED_VOL`.
3. Find the UUID of this filesystem.
4. Add a line to `/etc/fstab` that mounts this filesystem at `/mnt/recovered` by its **UUID**. The line must start with `UUID=` followed directly by the UUID, with no quotes.
5. Create the directory `/mnt/recovered` and mount the filesystem there using the `/etc/fstab` line.
