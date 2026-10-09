# Question

Solve this question on: `terminal`

Astronaut, mission control picked you for this job because you know cargo holds (disks) and the crew (processes) that use them. Three storage jobs are waiting on this ship. Solve all three.

1. **Prepare the new disk.** Find the disk that has no filesystem and no mount point yet (use `lsblk`). Format it with ext4, mount it at `/mnt/backup-black`, and create the empty file `/mnt/backup-black/completed`.
2. **Empty the right trash.** Two other disks are already mounted. Check `df -h` to see them, find the one with the higher storage usage, and empty the `.trash` folder on it. Keep the `.trash` folder itself.
3. **Free the right disk.** Two processes are running: `dark-matter-v1` and `dark-matter-v2`. Find the one that uses more memory (resident or virtual). Then unmount the disk that holds that process's executable file.

The grader checks the live machine: an ext4 filesystem mounted at `/mnt/backup-black` with an empty `completed` file, an empty `.trash` folder on the busier disk, and the disk of the bigger process unmounted with that process no longer running.
