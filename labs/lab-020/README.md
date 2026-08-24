# lab-020: Remote Filesystems: SSHFS and NFS

Two QEMU VMs for the LFCS course — `terminal` (SSHFS client + NFS server) and `app-srv1` (SSHFS/NFS-export source + NFS client), joined on a private `10.10.40.0/24` network.

## Access

`terminal`'s `sshAccess: [app-srv1]` config wires key-based SSH trust to `app-srv1` as the `student` user automatically — `ssh app-srv1` / `sshfs ... student@app-srv1:/data-export` from `terminal` just work, no password needed.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-020
```
