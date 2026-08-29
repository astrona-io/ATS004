# Overview: Securing Data-at-Rest with LUKS (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with `astrona ssh section-010-module-03-playground`.
- The system disk (`/dev/vda`) with the OS on it.
- One **extra 2 GB raw disk** — commonly `/dev/vdb`, also at
  `/dev/disk/by-id/virtio-s10m03-raw`. Wiped back to raw on every boot.
- `cryptsetup` and the `dm_crypt` kernel module, plus `mkfs.ext4`, `lsblk`,
  `blkid`, `xxd` from the LFCS image.
- Passwordless `sudo`.

## Things to try

- Format the disk as a LUKS2 container:
  `sudo cryptsetup luksFormat /dev/vdb` (type `YES`, then a passphrase).
- Inspect the header: `sudo cryptsetup luksDump /dev/vdb`.
- Open it: `sudo cryptsetup open /dev/vdb secure_vault`, then look at
  `/dev/mapper/`.
- Put ext4 on the *mapped* device, mount it, write a file, unmount, and
  `sudo cryptsetup close secure_vault`.
- Add a second passphrase with `sudo cryptsetup luksAddKey /dev/vdb` and see it
  as a second keyslot in `luksDump`.
- Look at the raw bytes: `sudo xxd -l 96 /dev/vdb` (a small `LUKS` header, then
  high-entropy noise).

## When you're done

```sh
astrona destroy section-010-module-03-playground
```

(`astrona destroy` takes the environment name, not the config path.)
