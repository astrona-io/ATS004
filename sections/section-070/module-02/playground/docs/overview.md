# Overview: Process-Level Auditing — Identifying the Culprit (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with
  `astrona ssh section-070-module-02-playground`.
- A **spare 4 GB disk** with ext4 mounted at `/mnt/perf`.
- `iotop`, `sysstat` (`pidstat`, `iostat`), `lsof`, and `fio` installed.
- `kernel.task_delayacct = 1` set via `/etc/sysctl.d/99-delayacct.conf` so
  `iotop` reports real numbers (it shows zeros without it on modern kernels).
- Helpers on `PATH`:
  - `start-io-load` — background a continuous writer to `/mnt/perf/leak.log`,
    prints its PID.
  - `stop-io-load` — stop it and remove the file.
- Passwordless `sudo` (`iotop` and full `lsof` output need root).

## Things to try

- `start-io-load`, then `sudo iotop -o -b -n 3` — find the writer and its rate.
- `pidstat -d 1 3` — the same per-process I/O without needing `iotop`.
- `sudo lsof -p <PID> | grep /mnt/perf` and `sudo lsof /mnt/perf/leak.log`.
- Chain it: `iostat -xz 1 2` (busy device) → `findmnt /mnt/perf` (device →
  mount) → `iotop`/`pidstat` (PID) → `lsof` (file).
- `stop-io-load` when done.

## When you're done

```sh
astrona destroy section-070-module-02-playground
```

(`astrona destroy` takes the environment name, not the config path.)
