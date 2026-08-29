# Overview: Network Automount Maps & Tuning (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs its
bootstrap scripts, and then waits. There is no task, no `astrona submit`, and no
pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

Two Ubuntu 24.04 VMs on a private `10.10.50.0/24` network:

| VM | Address | Role |
| --- | --- | --- |
| `client` | 10.10.50.5 | autofs client — `autofs` running, `nfs-common` + `showmount`, `/etc/auto.master` copied to `/etc/auto.master.orig` |
| `nfs` | 10.10.50.10 | NFS server exporting `/export/eng` and `/export/mkt` (each with one file), read-only, to `10.10.50.0/24` |

Reach them with `astrona ssh client` / `astrona ssh nfs`. `client` resolves
`nfs` from `/etc/hosts`.

## Things to try

On `client`:

- `showmount -e nfs` to see the two exports.
- Add to `/etc/auto.master`: `/mnt/dep  /etc/auto.dep  --timeout=15`
- Create `/etc/auto.dep` with explicit keys:
  ```text
  eng  -fstype=nfs,ro,soft  nfs:/export/eng
  mkt  -fstype=nfs,ro,soft  nfs:/export/mkt
  ```
- `sudo systemctl reload autofs`, then `ls /mnt/dep/eng` and `mount | grep nfs`.
- Leave it idle ~20 s and watch the NFS mount detach.
- Replace the two lines with one wildcard line:
  `*  -fstype=nfs,ro,soft  nfs:/export/&` — reload, then `ls /mnt/dep/mkt`.
- Roll back: `sudo cp /etc/auto.master.orig /etc/auto.master`,
  `sudo rm /etc/auto.dep`, `sudo systemctl reload autofs`.

## When you're done

```sh
astrona destroy section-050-module-02-playground
```

(`astrona destroy` takes the environment name, not the config path.)
