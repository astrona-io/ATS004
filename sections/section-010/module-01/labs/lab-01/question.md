# Question

Solve this question on: `terminal`

Astronaut, a new cargo hold has just been fitted to your training ship. It is a raw disk with no filesystem, and mission control wants it ready for backups. Build the shelves, dock it, and leave a marker so the inspection crew knows you finished.

1. Identify the raw, unformatted disk attached to your system (hint: use `lsblk` and `blkid`).
2. Format that disk with the **ext4** filesystem.
3. Create the directory `/mnt/backup-black` and mount the newly formatted disk on it.
4. Create an empty marker file named `completed` directly inside the mounted directory: `/mnt/backup-black/completed`.

The grader checks the live machine: an ext4 filesystem must be mounted at `/mnt/backup-black`, and the file `completed` must exist on it.
