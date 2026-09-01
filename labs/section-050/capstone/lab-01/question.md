# Question

Solve this question on: `app-srv1`

`app-srv1` occasionally needs access to an NFS export at `data-001:/exports/shared`, but the share should not be mounted permanently — it's used rarely, and a stale `fstab`-style mount has caused boot delays before when `data-001` was unreachable. Configure `autofs` so that:

Accessing `/mnt/auto/shared` on `app-srv1` automatically mounts `data-001:/exports/shared` on demand.

The mount is automatically released again after 5 minutes of inactivity.

No permanent `/etc/fstab` entry should be used for this share.
