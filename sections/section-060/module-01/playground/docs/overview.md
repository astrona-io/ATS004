# Overview: The Process Blueprint — Inside /proc (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with
  `astrona ssh section-060-module-01-playground`.
- `/srv/demo/one.log` and `/srv/demo/two.log` — files for a demo process to
  hold open.
- A helper on `PATH`, `start-demo-proc`, that launches a `tail -F` on both logs
  and prints its PID. Stop it with `pkill -f 'tail -F /srv/demo'`.
- Everything you need is in coreutils/procps: `cat`, `ls`, `tr`, `grep`, `wc`.
- Passwordless `sudo` (not needed for most of this — `/proc` is world-readable).

## Things to try

- `cat /proc/meminfo`, `cat /proc/cpuinfo`, `cat /proc/cmdline`.
- `ls -l /proc | head` — note the numbered directories and the 0-byte sizes.
- `start-demo-proc` to get a PID, then:
  - `cat /proc/<PID>/cmdline | tr '\0' ' '; echo`
  - `ls -l /proc/<PID>/fd/`
  - `ls /proc/<PID>/fd/ | wc -l` to count open descriptors
- `kill <PID>` and confirm `/proc/<PID>` disappears immediately.

## When you're done

```sh
astrona destroy section-060-module-01-playground
```

(`astrona destroy` takes the environment name, not the config path.)
