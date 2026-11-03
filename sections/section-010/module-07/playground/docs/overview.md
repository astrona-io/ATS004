# Overview: Removable Media and FAT32 (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with
  `astrona ssh section-010-module-07-playground`.
- One **blank 1 GB spare disk** with no filesystem (usually `/dev/vdb`, also
  `/dev/disk/by-id/virtio-s010m07-media`).
- `mkfs.vfat`, `fatlabel`, `blkid`, `lsblk`, `fallocate`. Passwordless `sudo`.

## Things to try

- `lsblk` and `sudo blkid /dev/vdb` — the disk is blank, so `blkid` prints nothing.
- `sudo mkfs.vfat -F 32 -n USBDATA /dev/vdb`, then `sudo blkid /dev/vdb`.
- `sudo fatlabel /dev/vdb` to read the label, `sudo fatlabel /dev/vdb TRAVEL_DRIVE` to change it.
- Mount it with no options and try `touch` as your user, then unmount and mount again
  with `-o uid=$(id -u),gid=$(id -g),umask=022`.
- `fallocate -l 4200M /mnt/usbdata/toobig.bin` to meet the file size limit.
- Start over: `sudo umount /mnt/usbdata`, then format the disk again.

## When you're done

```sh
astrona destroy section-010-module-07-playground
```

(`astrona destroy` takes the environment name, not the config path.)
