# Overview: XFS: Creating, Growing and Repairing (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with
  `astrona ssh section-010-module-09-playground`.
- Two **blank spare disks**: 1 GB (serial `s010m09-a`) and 2 GB (serial
  `s010m09-b`), commonly `/dev/vdb` and `/dev/vdc`.
- `/etc/fstab` copied to `/etc/fstab.orig` for rollback.
- `mkfs.xfs`, `xfs_info`, `xfs_growfs`, `xfs_repair`, `xfs_admin`, `blkid`,
  `findmnt`. Passwordless `sudo`.

## Things to try

- `sudo mkfs.xfs -L CARGO /dev/vdb`, mount it, then `xfs_info` on the mount point.
- Mount with `-o noatime` and read the options with `findmnt`.
- Add a `UUID=` line for it to `/etc/fstab`, then `sudo findmnt --verify` and
  `sudo mount -a`.
- Unmount and run `sudo xfs_repair -n` on it, then `echo $?`.
- Try `xfs_repair` on the mounted filesystem and read the refusal.
- Roll back: `sudo umount` the mounts, `sudo cp /etc/fstab.orig /etc/fstab`.

## When you're done

```sh
astrona destroy section-010-module-09-playground
```

(`astrona destroy` takes the environment name, not the config path.)
