# Question

Solve this question on: `terminal` (as the SSHFS client and NFS server) and `app-srv1` (as the SSHFS/NFS-export source and the NFS client)

On your main server `terminal` use SSHFS to mount directory `/data-export` from server `app-srv1` to `/app-srv1/data-export`. The mount should be read-write and option `allow_other` should be enabled.

The NFS service has been installed on your main server `terminal`. Directory `/nfs/share` should be read-only accessible from `10.10.40.0/24`. On `app-srv1`, mount the NFS share `/nfs/share` to `/nfs/terminal/share`.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-01](../../../module-01/course.md), [module-02](../../../module-02/course.md), [module-03](../../../module-03/course.md).

The grader checks:

- Confirms /app-srv1/data-export is mounted via fuse.sshfs, read-write, with allow_other set.
- Confirms /nfs/share is exported read-only to 10.10.40.0/24.
- Confirms /nfs/terminal/share is mounted from terminal's NFS export, type nfs, read-only.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
