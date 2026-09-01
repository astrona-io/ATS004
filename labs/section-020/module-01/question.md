# Question

Solve this question on: `terminal`

Establish an ad-hoc directory share over SSH.

The local machine has SSHFS installed, and a remote daemon is simulated locally on address `127.0.0.1`.
A user account `sshuser` has been created with password `password123`. The remote files are located at `/opt/remote-data`.

1. Create a mountpoint directory at `/mnt/sshfs-share`.
2. Securely mount `/opt/remote-data` from `sshuser@127.0.0.1` to `/mnt/sshfs-share` using `sshfs`.
3. Allow other users on the system to access the user-space mount.
4. Do not use permanent `/etc/fstab` configuration.
