# Question

Solve this question on: `terminal` (as the SSHFS client and NFS server) and `app-srv1` (as the SSHFS/NFS-export source and the NFS client)

On your main server `terminal` use SSHFS to mount directory `/data-export` from server `app-srv1` to `/app-srv1/data-export`. The mount should be read-write and option `allow_other` should be enabled.

The NFS service has been installed on your main server `terminal`. Directory `/nfs/share` should be read-only accessible from `10.10.40.0/24`. On `app-srv1`, mount the NFS share `/nfs/share` to `/nfs/terminal/share`.
