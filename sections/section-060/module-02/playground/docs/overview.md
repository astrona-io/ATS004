# Overview: The Hardware Tree & Runtime Tuning — /sys & sysctl (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with
  `astrona ssh section-060-module-02-playground`.
- A **1 GB spare disk** (commonly `/dev/vdb`) so `/sys/class/block/vdb/...`
  reads work on a device that is not the root disk.
- `sysctl`, `findmnt`, and the usual `cat`/`grep`; `/proc`, `/sys`, and
  `/proc/sys` are all mounted.
- Passwordless `sudo` (needed only for writes under `/proc/sys` and edits to
  `/etc/sysctl.d/`).

## Things to try

- `cat /sys/class/block/vdb/queue/hw_sector_size` and
  `cat /sys/class/block/vdb/size`.
- `cat /sys/class/net/*/address` to read interface MAC addresses.
- `cat /proc/mounts | grep ' / '` and `findmnt /` — compare; `ls -l /etc/mtab`.
- `sysctl net.ipv4.ip_forward`, then `sudo sysctl -w net.ipv4.ip_forward=1`, then
  `cat /proc/sys/net/ipv4/ip_forward`. Set it back with `=0`.
- Persist it: `echo 'net.ipv4.ip_forward = 1' | sudo tee /etc/sysctl.d/99-playground.conf`
  then `sudo sysctl --system`. Undo by removing that file.

## When you're done

```sh
astrona destroy section-060-module-02-playground
```

(`astrona destroy` takes the environment name, not the config path.)
