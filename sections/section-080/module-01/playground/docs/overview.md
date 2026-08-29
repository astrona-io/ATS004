# Overview: Directory Capacity Auditing (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with
  `astrona ssh section-080-module-01-playground`.
- A **second ext4 filesystem** on a spare disk, mounted at `/data`, holding a
  400 MiB file — so `du -x` has a real mount boundary to stop at.
- Seeded on the **root** filesystem:
  - `/opt/reports/big-real.bin` — 256 MiB of actual disk blocks.
  - `/opt/archive/sparse.img` — 512 MiB *apparent* size, almost nothing on disk.
  - `/opt/logs/` — 200 tiny files.
- `du`, `df`, `sort`, `findmnt` all present. Passwordless `sudo`.

## Things to try

- `du -h -d 1 /opt | sort -hr` — largest directories under `/opt` first.
- `du -hx -d 1 / | sort -hr` — root-filesystem audit; note `/data`, `/proc`,
  `/sys` do not contribute.
- Compare `du -h /opt/archive/sparse.img` with
  `du -h --apparent-size /opt/archive/sparse.img`.
- `du -sh /data` with and without `-x` from `/`.
- `df -h /` vs the `du -hx -d1 /` total — see where they disagree.

## When you're done

```sh
astrona destroy section-080-module-01-playground
```

(`astrona destroy` takes the environment name, not the config path.)
