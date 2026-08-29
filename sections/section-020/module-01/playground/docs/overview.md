# Overview: Ad-Hoc Mounting with SSHFS (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs its
bootstrap scripts, and then waits. There is no task, no `astrona submit`, and no
pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

Two Ubuntu 24.04 VMs on a private `10.10.20.0/24` network:

| VM | Address | Role |
| --- | --- | --- |
| `client` | 10.10.20.5 | SSHFS client — `sshfs` + FUSE installed, `/etc/fuse.conf` has `user_allow_other`, an extra local user `bob`, passwordless **root** SSH to `srv`, mount point `/mnt/remote` |
| `srv` | 10.10.20.10 | Plain SSH host exposing `/srv/logs` with `app.log`, `access.log` (world-readable) and `secret.txt` (root-only, mode 600) |

Reach them with `astrona ssh section-020-module-01-playground` (pick the VM when
prompted) or `astrona ssh client` / `astrona ssh srv`. The name `srv` resolves
from `/etc/hosts` on `client`.

## Things to try

Run these on `client`:

- `sudo sshfs srv:/srv/logs /mnt/remote` then `mount | grep fuse.sshfs`.
- `sudo -u bob ls /mnt/remote` — denied; remount with `-o allow_other` and retry.
- `sudo -u bob cat /mnt/remote/secret.txt` with `-o allow_other` vs
  `-o allow_other,default_permissions` — see which layer enforces the mode.
- `sudo umount /mnt/remote` (or `fusermount -u /mnt/remote`).

## When you're done

```sh
astrona destroy section-020-module-01-playground
```

(`astrona destroy` takes the environment name, not the config path.)
