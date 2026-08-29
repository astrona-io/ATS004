# Overview: Filesystem Maintenance, Labeling, and Tuning (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with `astrona ssh section-010-module-04-playground`.
- The system disk (`/dev/vda`) with the OS on it.
- One **extra 2 GB disk** (commonly `/dev/vdb`, also
  `/dev/disk/by-id/virtio-s10m04-fs`) holding an **unmounted** ext4 filesystem
  labelled `OLD_LABEL` with a couple of sample files. Rebuilt on every boot.
- `fsck` / `e2fsck`, `tune2fs`, `dumpe2fs`, `blkid`, `lsblk` from the LFCS image.
- Passwordless `sudo`.

## Things to try

- Read the superblock: `sudo tune2fs -l /dev/vdb` — note the state, mount count,
  features (`has_journal`), and UUID.
- Run a read-only check while it is unmounted: `sudo fsck -n /dev/vdb`.
- Relabel it: `sudo tune2fs -L NEW_LABEL /dev/vdb`, then `sudo blkid /dev/vdb`.
- Mount it by label and by UUID:
  `sudo mount LABEL=NEW_LABEL /mnt/x` / `sudo mount UUID=<uuid> /mnt/x`.
- Change the check interval: `sudo tune2fs -c 20 /dev/vdb` and re-read with
  `tune2fs -l`.
- See what happens if you run `sudo fsck /dev/vdb` *while it is mounted* (it
  warns you and refuses / asks — do not force it).

## When you're done

```sh
astrona destroy section-010-module-04-playground
```

(`astrona destroy` takes the environment name, not the config path.)
