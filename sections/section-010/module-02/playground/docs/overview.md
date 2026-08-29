# Overview: Partitioning Raw Storage (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with `astrona ssh section-010-module-02-playground`.
- The system disk (`/dev/vda`) with the OS on it.
- One **extra 12 GB disk** with no partition table — commonly `/dev/vdb`, also
  at `/dev/disk/by-id/virtio-s10m02-raw`. `bootstrap/prepare.sh` clears its
  partition tables on every boot.
- Partitioning tools from the LFCS image: `fdisk`, `parted`, `sfdisk`,
  `partprobe`, `lsblk`, `blkid`, `wipefs`.
- Passwordless `sudo`.

## Things to try

- Inspect the empty disk: `sudo fdisk -l /dev/vdb` and `lsblk /dev/vdb`.
- Write a GPT label and a partition interactively with `sudo fdisk /dev/vdb`
  (`g`, then `n`, then `w`).
- Do the same non-interactively with `parted`:
  `sudo parted -s /dev/vdb mklabel gpt mkpart data ext4 1MiB 10GiB`.
- Check alignment: `sudo parted /dev/vdb align-check optimal 1`.
- Delete the partition, notice `lsblk` still shows it, then run
  `sudo partprobe /dev/vdb` and look again.
- Reset to raw: `sudo wipefs -a /dev/vdb`.

## When you're done

```sh
astrona destroy section-010-module-02-playground
```

(`astrona destroy` takes the environment name, not the config path.)
