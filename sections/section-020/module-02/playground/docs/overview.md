# Overview: Enterprise Sharing with NFS (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs its
bootstrap scripts, and then waits. There is no task, no `astrona submit`, and no
pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

Two Ubuntu 24.04 VMs on a private `10.10.20.0/24` network:

| VM | Address | Role |
| --- | --- | --- |
| `server` | 10.10.20.10 | NFS server — `nfs-kernel-server` running, `/nfs/share` seeded with `report.txt` and `notes.txt`, `/etc/exports` **empty** (a comment only) |
| `client` | 10.10.20.5 | NFS client — `nfs-common` and `showmount` installed, mount point `/mnt/nfs` |

Reach them with `astrona ssh server` / `astrona ssh client`. Each resolves the
other's name from `/etc/hosts`.

## Things to try

On `server`:

- Add an export: append `/nfs/share 10.10.20.0/24(ro,sync,no_subtree_check)` to
  `/etc/exports`, then `sudo exportfs -arv` and `sudo exportfs -v`.
- Switch `ro` to `rw`, re-export, and see the client's write behaviour change.

On `client`:

- `showmount -e server` to list what `server` offers.
- `sudo mount -t nfs server:/nfs/share /mnt/nfs`, then read a file.
- `sudo touch /mnt/nfs/x` against a read-only export — observe the error.
- Remount with `-o soft,timeo=30,retrans=2` and inspect the option string in
  `mount`.

## When you're done

```sh
astrona destroy section-020-module-02-playground
```

(`astrona destroy` takes the environment name, not the config path.)
