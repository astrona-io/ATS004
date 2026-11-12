# Question

Solve this question on: `terminal`

A Volume Group named `vg_xfs` exists on a single disk. It holds a Logical Volume named `lv_xfs`, formatted with the **XFS** filesystem (not ext4), mounted at `/mnt/lvm-xfs` and serving live data.

- Disk: `/dev/disk/by-id/virtio-lab086-disk1`

1. Grow `lv_xfs` by `400M` using `lvextend`.
2. Grow the XFS filesystem to match, using the correct tool for XFS — `resize2fs` does **not** work on XFS filesystems.
3. Confirm the mounted filesystem now reports the larger size, and that the file already on it survived untouched.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-02](../../course.md).

The grader checks:

- Confirms lv_xfs was grown with lvextend and the XFS filesystem was grown with xfs_growfs, data intact.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
