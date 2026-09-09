# Question

Solve this question on: `terminal`

Automate mounting of a local directory on-demand.

1. Ensure `autofs` is installed and the daemon is running.
2. Configure a direct map so that accessing `/mnt/secure_archive` automatically mounts the local folder `/var/data/archive` using a bind mount.
3. Set the direct map timeout to exactly **60** seconds so that inactivity leads to automatic unmounting.
4. Do not list `/mnt/secure_archive` in `/etc/fstab`.
