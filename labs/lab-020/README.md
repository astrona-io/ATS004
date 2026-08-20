# lab-020: Remote Filesystems: SSHFS and NFS

Two QEMU VMs for the LFCS course — `terminal` (SSHFS client + NFS server) and `app-srv1` (SSHFS/NFS-export source + NFS client), joined on a private `10.10.40.0/24` network.

## Credentials

`app-srv1`'s root account uses password authentication for this lab:

```
password: AstronaLab2024!
```

Needed for `ssh app-srv1` / `sshfs ... app-srv1:/data-export` from `terminal`.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-020
```
