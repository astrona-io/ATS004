# Overview: On-Demand Mounting Fundamentals (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with
  `astrona ssh section-050-module-01-playground`.
- `autofs` installed (service **not** started — the chapter enables it).
- `/srv/localdata/` with `hello.txt` and `notes.txt` — the chapter maps this
  through autofs as a bind mount, so no NFS server is needed to see the
  trigger-and-timeout mechanic.
- `/etc/auto.master` copied to `/etc/auto.master.orig` for one-command rollback.
- Passwordless `sudo`.

## Things to try

- `sudo systemctl enable --now autofs`, then `systemctl status autofs`.
- Add to `/etc/auto.master`: `/mnt/auto  /etc/auto.demo  --timeout=15`
- Create `/etc/auto.demo` with: `data  -fstype=bind  :/srv/localdata`
- `sudo systemctl reload autofs`, then `mount | grep autofs`.
- `ls /mnt/auto/data` — the bind mount appears on access; `mount | grep /mnt/auto`.
- Leave it idle ~20 s, then `mount | grep /mnt/auto` again — it is gone.
- Roll back: `sudo cp /etc/auto.master.orig /etc/auto.master`,
  `sudo rm /etc/auto.demo`, `sudo systemctl reload autofs`.

## When you're done

```sh
astrona destroy section-050-module-01-playground
```

(`astrona destroy` takes the environment name, not the config path.)
