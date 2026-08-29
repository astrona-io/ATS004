# Overview: /etc/fstab in Depth (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with
  `astrona ssh section-010-module-05-playground`.
- **Two spare 1 GB disks**, each with an ext4 filesystem (labels `DATA1`,
  `DATA2`) — something real to add to `/etc/fstab`.
- `/etc/fstab` copied to `/etc/fstab.orig` for one-command rollback.
- `findmnt`, `blkid`, `lsblk`, `mount` all present. Passwordless `sudo`.

## Things to try

- `findmnt --fstab` and `cat /etc/fstab` — the current entries and their fields.
- `sudo blkid` — collect the UUIDs of the two spare filesystems.
- Add a line like `UUID=<uuid>  /mnt/data1  ext4  defaults,nofail  0  2`,
  `sudo mkdir -p /mnt/data1`, `sudo mount -a`, `findmnt /mnt/data1`.
- `findmnt --verify` — sanity-check the file; add a broken line and watch it
  get flagged.
- Add an entry with a bad UUID and no `nofail`, run `sudo mount -a`, see it
  fail loudly (this is what would drop a real boot to the emergency shell).
- Roll back: `sudo cp /etc/fstab.orig /etc/fstab`.

## When you're done

```sh
astrona destroy section-010-module-05-playground
```

(`astrona destroy` takes the environment name, not the config path.)
