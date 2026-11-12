# Question

Solve this question on: `terminal`

Astronaut, mission control gave you two cargo holds. The disk `/dev/disk/by-id/virtio-lab091-new` is blank. The disk `/dev/disk/by-id/virtio-lab091-old` already holds an XFS filesystem with the label `OLDCARGO`, and it is not mounted.

1. Format the blank disk as an **XFS** filesystem with the label `NEWCARGO`.
2. Create the mount point `/srv/newcargo`.
3. Make the mount permanent: add a line to `/etc/fstab` that mounts the filesystem at `/srv/newcargo` by its `UUID=`, with the type `xfs` and the options `defaults,noatime`. Then mount it with `sudo mount -a`.
4. Run a dry-run repair check on the old disk, without changing it and without mounting it. Save everything the tool prints to `/home/ubuntu/oldcargo-check.txt`.

The grader checks the live machine: the type and label on both disks, the line in `/etc/fstab`, what is mounted at `/srv/newcargo` and with which options, that the old disk is still unmounted and its data is intact, and the saved check output.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-09](../../course.md).

The grader checks:

- Confirms the XFS label, the UUID-based fstab mount, and a saved dry-run repair of the untouched old disk.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
