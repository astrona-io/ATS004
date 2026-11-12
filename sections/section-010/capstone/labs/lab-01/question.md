# Question

Solve this question on: `terminal`

Astronaut, mission control picked you for this job because you know cargo holds (disks) and the crew (processes) that use them. Three storage jobs are waiting on this ship. Solve all three.

1. **Prepare the new disk.** Find the disk that has no filesystem and no mount point yet (use `lsblk`). Format it with ext4, mount it at `/mnt/backup-black`, and create the empty file `/mnt/backup-black/completed`.
2. **Empty the right trash.** Two other disks are already mounted. Check `df -h` to see them, find the one with the higher storage usage, and empty the `.trash` folder on it. Keep the `.trash` folder itself.
3. **Free the right disk.** Two processes are running: `dark-matter-v1` and `dark-matter-v2`. Find the one that uses more memory (resident or virtual). Then unmount the disk that holds that process's executable file.

The grader checks the live machine: an ext4 filesystem mounted at `/mnt/backup-black` with an empty `completed` file, an empty `.trash` folder on the busier disk, and the disk of the bigger process unmounted with that process no longer running.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-01](../../../module-01/course.md), [module-02](../../../module-02/course.md), [module-03](../../../module-03/course.md), [module-04](../../../module-04/course.md), [module-05](../../../module-05/course.md), [module-06](../../../module-06/course.md), [module-07](../../../module-07/course.md), [module-08](../../../module-08/course.md), [module-09](../../../module-09/course.md), [module-10](../../../module-10/course.md).

The grader checks:

- Confirms an ext4 filesystem is mounted at /mnt/backup-black, regardless of which /dev/vdX it landed on.
- Confirms /mnt/backup-black/completed exists as an empty regular file.
- Confirms the disk with higher df Used (computed live, not hardcoded) has an empty .trash directory.
- Confirms the disk backing dark-matter-v2's executable (/mnt/backup-red, the higher-memory process) is unmounted.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
