# Overview: LVM Fundamentals (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with `astrona ssh section-030-module-01-playground`.
- The system disk (`/dev/vda`) with the OS on it.
- **Three spare 1 GB disks** with no LVM metadata and no filesystem — commonly
  `/dev/vdb`, `/dev/vdc`, `/dev/vdd` (also `/dev/disk/by-id/virtio-s30m01-a|b|c`).
  Wiped on every boot.
- `lvm2` installed: `pvcreate`, `pvs`, `pvdisplay`, `vgcreate`, `vgs`,
  `vgdisplay`, `lvcreate`, `lvs`, `lvdisplay`.
- Passwordless `sudo`.

## Things to try

- `sudo pvcreate /dev/vdb /dev/vdc`, then `sudo pvs` and `sudo pvdisplay`.
- `sudo vgcreate vgdata /dev/vdb /dev/vdc`, then `sudo vgs` /
  `sudo vgdisplay vgdata` — note the total size and the 4 MiB extent size.
- `sudo lvcreate -n applv -L 200M vgdata`, then `sudo lvs -o +devices` to see
  which physical disks the volume's extents came from.
- `sudo mkfs.ext4 /dev/vgdata/applv`, mount it, write a file, `df -h`.
- Tear it all down: `sudo lvremove vgdata/applv`, `sudo vgremove vgdata`,
  `sudo pvremove /dev/vdb /dev/vdc`, and start over.

## When you're done

```sh
astrona destroy section-030-module-01-playground
```

(`astrona destroy` takes the environment name, not the config path.)
