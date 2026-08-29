# Overview: Permanent Swap Partitions & Priority Scheduling (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM (2 GB RAM), reached with
  `astrona ssh section-040-module-02-playground`.
- One **spare 1 GB disk** (commonly `/dev/vdb`, also
  `/dev/disk/by-id/virtio-s40m02-swap`), wiped raw on every boot — partition it
  for swap.
- `/etc/fstab` backed up to `/etc/fstab.orig` so edits are easy to roll back.
- Tools: `parted`, `partprobe`, `mkswap`, `swapon`, `swapoff`, `blkid`,
  `fallocate`, `free`.
- Passwordless `sudo`.

## Things to try

- Partition the spare disk: `sudo parted -s /dev/vdb mklabel gpt` then
  `sudo parted -s /dev/vdb mkpart swap linux-swap 1MiB 100%`.
- `sudo mkswap /dev/vdb1`, `sudo swapon /dev/vdb1`, `swapon --show`.
- Make a small swap file too, then compare fill order:
  `sudo swapon -p 10 /dev/vdb1` and `sudo swapon -p 5 /swapfile`.
- Add both to `/etc/fstab` (partition by `UUID=`, with `pri=`), then
  `sudo swapoff -a && sudo swapon -a` to apply.
- Roll back: `sudo cp /etc/fstab.orig /etc/fstab`.

## When you're done

```sh
astrona destroy section-040-module-02-playground
```

(`astrona destroy` takes the environment name, not the config path.)
