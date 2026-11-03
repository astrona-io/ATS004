# Overview: Network Block Devices (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs its
bootstrap scripts, and then waits. There is no task, no `astrona submit`, and no
pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

Two Ubuntu 24.04 VMs on a private `10.10.60.0/24` network:

| VM | Address | Role |
| --- | --- | --- |
| `server` | 10.10.60.10 | iSCSI target `iqn.2026-01.io.astrona:storage.cargo` (tgt, port 3260) with one 1 GB disk, and an NBD export named `cargo` (port 10809) with 512 MB |
| `client` | 10.10.60.5 | `nbd-client` and `open-iscsi` installed, `iscsid` running, mount point `/mnt/cargo`, nothing connected |

The tools are installed with `apt` when the machines start, so the first boot
needs a working network. Reach them with `astrona ssh section-020-module-03-playground`
and choose `server` or `client`. Each resolves the other's name from `/etc/hosts`.

## Things to try

On `client`:

- `sudo nbd-client -l server` to list the NBD exports, then connect `cargo` to
  `/dev/nbd0`, format it, mount it, and disconnect it again.
- `sudo iscsiadm -m discovery -t sendtargets -p 10.10.60.10` to find the target.
- Log in with `iscsiadm -m node ... --login`, find the new disk with `lsblk`,
  format and mount it at `/mnt/cargo`.
- Add a `_netdev` line to `/etc/fstab`, check it with `sudo findmnt --verify`.
- Log out and see the disk disappear.

## When you're done

```sh
astrona destroy section-020-module-03-playground
```
