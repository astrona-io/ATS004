# Overview: systemd Mount and Automount Units (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with
  `astrona ssh section-010-module-06-playground`.
- One **spare 1 GB disk** with an ext4 filesystem (label `DATA`).
- `/etc/fstab` copied to `/etc/fstab.orig` for rollback.
- `systemctl`, `systemd-escape`, `findmnt`, `blkid`. Passwordless `sudo`.

## Things to try

- `systemctl list-units --type=mount` — every mount is a systemd unit, including
  the ones generated from `/etc/fstab`.
- `systemd-escape -p --suffix=mount /srv/data` — the unit name for that path.
- Write `/etc/systemd/system/srv-data.mount` with a `[Mount]` section,
  `sudo systemctl daemon-reload`, `sudo systemctl start srv-data.mount`,
  `findmnt /srv/data`.
- Add a paired `srv-data.automount` unit, `systemctl enable --now
  srv-data.automount`, then `ls /srv/data` to trigger the mount on demand.
- The fstab shortcut: an entry with
  `x-systemd.automount,x-systemd.idle-timeout=30` gives the same on-demand
  behaviour with no unit files.
- Roll back: remove the unit files + `sudo cp /etc/fstab.orig /etc/fstab`, then
  `sudo systemctl daemon-reload`.

## When you're done

```sh
astrona destroy section-010-module-06-playground
```

(`astrona destroy` takes the environment name, not the config path.)
