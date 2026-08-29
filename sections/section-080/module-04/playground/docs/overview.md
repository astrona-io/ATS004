# Overview: Navigating Shortcuts — Symbolic Links & FHS (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with
  `astrona ssh section-080-module-04-playground`.
- The distro's **usrmerge symlinks** already present: `/bin`, `/sbin`, `/lib`,
  `/lib64` are symlinks into `/usr/...`.
- `/srv/www/active` — a sample symlink to `/srv/releases/v2`, with `v1` and `v2`
  both present, to resolve and inspect.
- `/tmp/rmdemo/real` (two files) and `/tmp/rmdemo/link -> /tmp/rmdemo/real` — a
  **disposable** layout for the trailing-slash `rm` lesson. Rebuild it any time
  with `reset-symlink-demo`.
- `find`, `readlink`, `realpath`, `namei`, `ls` all present. Passwordless `sudo`.

## Things to try

- `find / -maxdepth 1 -type l -ls` — the top-level symlinks.
- `readlink /bin` vs `readlink -f /bin` vs `realpath /bin`.
- `namei -l /bin/ls` — the full resolution chain.
- `du -sh /bin` vs `du -sh /usr/bin` — a symlink weighs nothing.
- `ls -ld /srv/www/active`; repoint it with `ln -sfn /srv/releases/v1 /srv/www/active`.
- On the disposable demo: `rm /tmp/rmdemo/link` (no slash) removes only the
  link; `real` survives. Then `reset-symlink-demo`. See the chapter's warning
  about what a **trailing slash** does before trying that form.

## When you're done

```sh
astrona destroy section-080-module-04-playground
```

(`astrona destroy` takes the environment name, not the config path.)
