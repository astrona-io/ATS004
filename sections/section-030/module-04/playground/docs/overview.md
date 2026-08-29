# Overview: RAID Maintenance and Recovery (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with
  `astrona ssh section-030-module-04-playground`.
- A **pre-built RAID 5** at `/dev/md0` across three 1 GB disks, with an ext4
  filesystem mounted at `/mnt/raid` holding sample data.
- A **fourth 1 GB disk left raw** as the replacement.
- `/etc/mdadm/mdadm.conf` already written; `/etc/playground-raid` records which
  kernel device is `member1`/`member2`/`member3`/`spare` so you never guess.
- `mdadm` installed. Passwordless `sudo`.

## Things to try

- `cat /proc/mdstat`, `sudo mdadm --detail /dev/md0` — clean, 3 active devices.
- `. /etc/playground-raid`, then fail one:
  `sudo mdadm --manage /dev/md0 --fail "$member2"` — array goes degraded,
  `[U_U]`, data still readable from `/mnt/raid`.
- Replace it: `sudo mdadm --manage /dev/md0 --remove "$member2"`,
  `sudo mdadm --manage /dev/md0 --add "$spare"` — watch the rebuild in
  `/proc/mdstat`.
- Grow: re-add the cleaned disk and
  `sudo mdadm --grow /dev/md0 --raid-devices=4`, then
  `sudo resize2fs /dev/md0`.
- `sudo mdadm --monitor --scan --oneshot --test` — see what an alert looks like.

## When you're done

```sh
astrona destroy section-030-module-04-playground
```

(`astrona destroy` takes the environment name, not the config path.)
