# Overview: XFS Quotas and Project Quotas (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with
  `astrona ssh section-080-module-03-playground`.
- A **2 GB XFS filesystem mounted at `/srv/xfs`**, with `uquota,pquota` in its
  `/etc/fstab` options — so user and project quota accounting are already
  active (XFS enables quotas at mount time; there is no `quotacheck`).
- A directory tree `/srv/xfs/webdata` and test users **alice**, **bob**.
- No `/etc/projects`, `/etc/projid`, or limits defined yet.
- `xfs_quota` (from `xfsprogs`). Passwordless `sudo`. `/etc/fstab` backed up.

## Things to try

- `sudo xfs_quota -x -c 'state' /srv/xfs` — see accounting/enforcement flags.
- `sudo xfs_quota -x -c 'limit bsoft=40m bhard=50m alice' /srv/xfs`, then
  `sudo xfs_quota -x -c 'report -h' /srv/xfs`; exceed it as alice with `dd`.
- Define a project: add `42:/srv/xfs/webdata` to `/etc/projects` and
  `webdata:42` to `/etc/projid`, then
  `sudo xfs_quota -x -c 'project -s webdata' /srv/xfs`.
- `sudo xfs_quota -x -c 'limit -p bhard=100m webdata' /srv/xfs`; write into
  `/srv/xfs/webdata` as both alice and bob and watch the *combined* usage stop
  at 100 MiB. `sudo xfs_quota -x -c 'report -p -h' /srv/xfs`.
- Roll back: `sudo cp /etc/fstab.orig /etc/fstab`.

## When you're done

```sh
astrona destroy section-080-module-03-playground
```

(`astrona destroy` takes the environment name, not the config path.)
