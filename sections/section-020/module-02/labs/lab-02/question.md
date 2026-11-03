# Question

Solve this question on: `terminal`

Astronaut, this ship plays both sides of two remote holds, and mission control wants both docked at every launch. The NFS hold is broken and the SSHFS hold has no logbook entry yet.

- NFS share: the directory `/srv/nfs/reports` on this ship, reached through `127.0.0.1`. It holds `q4-report.txt`.
- SSHFS share: the directory `/opt/remote-data` of the user `sshuser`, reached through `localhost`. It holds `welcome.txt`. `root` already has a key file at `/root/.ssh/id_ed25519` that `sshuser` accepts, and `root` already trusts the host key.

1. Find out why `sudo mount -t nfs 127.0.0.1:/srv/nfs/reports /mnt/nfs-reports` is refused. Fix `/etc/exports` so that this ship may mount the share **read-only**, and make the server apply the change.
2. Add a line to `/etc/fstab` that docks `127.0.0.1:/srv/nfs/reports` at `/mnt/nfs-reports` as an `nfs` mount. Use the options `_netdev` and `nofail`, and mount it read-only.
3. Add a line to `/etc/fstab` that docks `sshuser@localhost:/opt/remote-data` at `/mnt/sshfs-logs` as a `fuse.sshfs` mount. Use the options `_netdev` and `allow_other`, and name root's key file with `IdentityFile=`.
4. Check the file with `sudo findmnt --verify`, then bring both mounts up with `sudo mount -a`.

The grader reads `/etc/fstab`, unmounts both shares, runs `mount -a` and checks that both come back: the NFS mount must be read-only and show `q4-report.txt`, and the SSHFS mount must show `welcome.txt`.
