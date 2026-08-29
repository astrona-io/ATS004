# Overview: Device-Level Diagnostics — Queues & Latency (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with
  `astrona ssh section-070-module-01-playground`.
- A **spare 4 GB disk** (commonly `/dev/vdb`) with an ext4 filesystem mounted
  at `/mnt/perf` — stress this, not the root disk.
- `sysstat` (`iostat`, `pidstat`) and `fio` installed.
- Two helpers on `PATH`:
  - `start-io-load seq` — high-throughput sequential writes to `/mnt/perf`.
  - `start-io-load rand` — high-IOPS small random writes to `/mnt/perf`.
  - `stop-io-load` — stop any running load.
- Passwordless `sudo`.

## Things to try

- `iostat -xz 1` in one shell; `start-io-load seq` in another. Watch `%util`,
  `aqu-sz`, `w_await`, `wkB/s`, `w/s` for the `/mnt/perf` device.
- `stop-io-load`, then `start-io-load rand` and compare: small random writes
  push `w/s` (IOPS) up while `wkB/s` stays modest.
- `findmnt /mnt/perf` to map the busy device back to its mount point.
- Note: this disk is virtio-backed, so seek penalties are small — the
  IOPS-vs-throughput gap is narrower than on a spinning disk.

## When you're done

```sh
astrona destroy section-070-module-01-playground
```

(`astrona destroy` takes the environment name, not the config path.)
