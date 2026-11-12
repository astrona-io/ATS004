# Question

Solve this question on: `terminal`

Configure NFS-based shared storage inside the enterprise environment.

1. Export the local directory `/var/nfs/public` as a **read-only** share available to all client machines (use wildcard `*`).
2. Make sure NFS exports are re-read and active.
3. Create a client-side mountpoint at `/mnt/nfs-share`.
4. Mount the NFS share locally (from `127.0.0.1:/var/nfs/public`) onto `/mnt/nfs-share` using NFS.
5. Verify that the files are readable but writing is forbidden.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-02](../../course.md).

The grader checks:

- Confirms NFS export status and client mounting.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
