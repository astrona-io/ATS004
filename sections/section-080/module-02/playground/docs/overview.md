# Overview: User and Group Disk Quotas (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with
  `astrona ssh section-080-module-02-playground`.
- A **2 GB ext4 filesystem mounted at `/quota`**, with `usrquota,grpquota` in
  its `/etc/fstab` options — but quotas are **not turned on yet**.
- Test users **alice** and **bob**, group **team** (both members), and owned
  subdirectories `/quota/alice`, `/quota/bob`, `/quota/team`.
- The `quota` package (`quotacheck`, `quotaon`, `setquota`, `edquota`,
  `repquota`, `quota`). Passwordless `sudo`. `/etc/fstab` backed up.

## Things to try

- `sudo quotacheck -cugv /quota` then `sudo quotaon -v /quota`; check with
  `sudo quotaon -p /quota`.
- `sudo setquota -u alice 40M 50M 0 0 /quota` (soft 40M, hard 50M);
  `sudo repquota -s /quota`.
- As alice, exceed it: `sudo -u alice dd if=/dev/zero of=/quota/alice/f bs=1M count=60`.
- Set a grace period: `sudo setquota -t 3600 3600 /quota`; watch the grace
  column in `sudo repquota -s /quota`.
- Group quota: `sudo setquota -g team 80M 100M 0 0 /quota`.
- Roll back: `sudo quotaoff /quota`, `sudo cp /etc/fstab.orig /etc/fstab`.

## When you're done

```sh
astrona destroy section-080-module-02-playground
```

(`astrona destroy` takes the environment name, not the config path.)
