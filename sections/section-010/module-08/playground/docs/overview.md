# Overview: Backing Up and Cloning Storage Devices (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with
  `astrona ssh section-010-module-08-playground`.
- A **1 GB source disk** (usually `/dev/vdb`) with an ext4 filesystem, label
  `SOURCEVOL`, holding `hello.txt`.
- A **blank 1 GB clone disk** (usually `/dev/vdc`).
- `dd`, `tar`, `sha256sum`, `cmp`, `lsblk`, `blkid`. Passwordless `sudo`.

## Things to try

- `lsblk` and `sudo blkid` — tell the source disk from the blank one.
- `sudo dd if=/dev/vdb of=/dev/vdc bs=4M status=progress` to clone the source onto the clone disk.
- `sudo sha256sum /dev/vdb /dev/vdc` or `sudo cmp /dev/vdb /dev/vdc` to prove the copy.
- `sudo dd if=/dev/vdb of=/root/vdb-backup.img bs=4M` to copy a disk into an image file.
- Mount the source and pack it with `tar -czpf`, then unpack it somewhere else.

## When you're done

```sh
astrona destroy section-010-module-08-playground
```

(`astrona destroy` takes the environment name, not the config path.)
