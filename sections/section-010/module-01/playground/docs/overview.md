# Overview: The Lifecycle of Local Storage (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with `astrona ssh section-010-module-01-playground`.
- The system disk (`/dev/vda`) with the OS on it, mounted at `/`.
- One **extra 2 GB disk** attached raw and unformatted — commonly `/dev/vdb`,
  also reachable at `/dev/disk/by-id/virtio-s10m01-raw`. `bootstrap/prepare.sh`
  wipes it back to raw on every boot.
- Standard storage tooling from the LFCS image: `lsblk`, `blkid`, `mkfs.ext4`,
  `mount`, `df`, `lsof`, `fuser`.
- Passwordless `sudo` for the login user.

## Things to try

- Run `lsblk` and `sudo blkid` and pick out which device is the raw disk.
- Format the raw disk with `sudo mkfs.ext4 /dev/vdb`, then compare `sudo blkid`
  before and after.
- Mount it somewhere under `/mnt`, write a file, and watch `df -h` change.
- Hold the mount "busy" from a second shell (`cd` into it, or `tail -f` a file
  there), try to `umount` it, and use `lsof +D` / `fuser -mv` to find what is
  holding it.
- Wipe the disk and start over: `sudo wipefs -a /dev/vdb`.

## When you're done

```sh
astrona destroy section-010-module-01-playground
```

(`astrona destroy` takes the environment name, not the config path.)
