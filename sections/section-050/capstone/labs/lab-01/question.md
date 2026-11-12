# Question

Solve this question on: `app-srv1`

`app-srv1` occasionally needs access to an NFS export at `data-001:/exports/shared`, but the share should not be mounted permanently — it's used rarely, and a stale `fstab`-style mount has caused boot delays before when `data-001` was unreachable. Configure `autofs` so that:

Accessing `/mnt/auto/shared` on `app-srv1` automatically mounts `data-001:/exports/shared` on demand.

The mount is automatically released again after 5 minutes of inactivity.

No permanent `/etc/fstab` entry should be used for this share.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-01](../../../module-01/course.md), [module-02](../../../module-02/course.md).

The grader checks:

- Confirms /exports/shared is actively exported by data-001's NFS server.
- Confirms /etc/fstab has no entry for the shared export -- autofs must be used instead of a permanent mount.
- Confirms an autofs master map references /mnt/auto and an indirect map file whose entry points at data-001:/exports/shared.
- Confirms the idle-unmount timeout is set to 300 seconds, either on the master map's mount-point line or in /etc/autofs.conf.
- Triggers access to /mnt/auto/shared and confirms the NFS mount actually appears live.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
