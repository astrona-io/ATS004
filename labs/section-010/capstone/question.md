# Question

Solve this question on: `terminal`

Your team selected you for this task because of your deep filesystem and disk/devices expertise. Solve the following steps:

Find the disk that has no filesystem and no mountpoint yet (use `lsblk`), format it with ext4, mount it to `/mnt/backup-black` and create empty file `/mnt/backup-black/completed`.

Two other disks are already mounted. Check `df -h` to see them, find which one has higher storage usage, then empty the `.trash` folder on it.

There are two processes running: `dark-matter-v1` and `dark-matter-v2`. Find the one that consumes more memory or virtual memory. Then unmount the disk where the process executable is located on.
