# Question

Solve this question on: `client`

Astronaut, the storage ship `server` (10.10.60.10) offers one empty disk over iSCSI. The name of its target is `iqn.2026-01.io.astrona:storage.cargo`. Mission control wants that disk docked on your ship at `/mnt/cargo`, and it must come back by itself after a restart.

1. Discover the targets that `server` offers.
2. Log in to the target `iqn.2026-01.io.astrona:storage.cargo`.
3. Find the new disk, and create an **ext4** filesystem on it.
4. Mount it at `/mnt/cargo`.
5. Make the mount persistent: add a line to `/etc/fstab` that uses the filesystem's `UUID=` and the `_netdev` option.
6. Make the login automatic: set `node.startup` of this target to `automatic`.

The grader checks the live `client` machine: it looks for an open iSCSI session to the target, checks that `/mnt/cargo` is mounted from that iSCSI disk as ext4, reads the `/etc/fstab` line, and reads the `node.startup` value.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-01](../../../module-01/course.md), [module-02](../../../module-02/course.md), [module-03](../../course.md).

The grader checks:

- Confirms an iSCSI session, an ext4 filesystem on the iSCSI disk mounted at /mnt/cargo, and a UUID= fstab line with _netdev.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
