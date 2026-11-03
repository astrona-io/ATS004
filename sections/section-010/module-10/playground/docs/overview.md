# Overview: Btrfs Basics (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with
  `astrona ssh section-010-module-10-playground`.
- Two **blank spare disks**: 2 GB (`/dev/disk/by-id/virtio-s010m10-a`) and
  1 GB (`/dev/disk/by-id/virtio-s010m10-b`).
- `btrfs-progs` installed by the preparation script if it was missing.
- `/etc/fstab` copied to `/etc/fstab.orig` for rollback.

## Things to try

- `sudo mkfs.btrfs -L VAULT` on the 2 GB disk, then mount it and run
  `btrfs filesystem show`, `df` and `usage` on the mount point.
- `btrfs subvolume create`, `btrfs subvolume list`, and mount one subvolume
  with `-o subvol=`.
- A persistent mount by `UUID=` with `subvol=` in `/etc/fstab`, checked with
  `sudo mount -a`.
- Read-only and writable snapshots, then `btrfs subvolume delete`.
- `btrfs filesystem resize -200M` and `resize max` on the mounted filesystem.
- Roll back: `sudo cp /etc/fstab.orig /etc/fstab`.

## When you're done

```sh
astrona destroy section-010-module-10-playground
```

(`astrona destroy` takes the environment name, not the config path.)
