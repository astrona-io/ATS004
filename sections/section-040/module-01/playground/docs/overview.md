# Overview: Temporary Safety Valves — Swap Files (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM (2 GB RAM), reached with
  `astrona ssh section-040-module-01-playground`.
- An **ext4 root filesystem** with plenty of free space for a swap file.
- Swap tooling: `fallocate`, `mkswap`, `swapon`, `swapoff`, `free`.
- Whatever swap the base image ships with (often none) — `swapon --show` at
  start tells you.
- Passwordless `sudo`.

## Things to try

- `free -h` and `swapon --show` to see the baseline.
- `sudo fallocate -l 512M /swapfile`, then `ls -lh /swapfile` and
  `sudo chmod 600 /swapfile`.
- `sudo mkswap /swapfile`, `sudo swapon /swapfile`, then `swapon --show` and
  `free -h` — watch the swap total rise.
- `sudo swapoff /swapfile` and confirm it leaves the list; `sudo rm /swapfile`.
- Try `sudo swapon /swapfile` while the file is mode `644` and read the warning.

## When you're done

```sh
astrona destroy section-040-module-01-playground
```

(`astrona destroy` takes the environment name, not the config path.)
