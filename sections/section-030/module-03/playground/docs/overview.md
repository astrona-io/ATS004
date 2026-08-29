# Overview: Software RAID Fundamentals (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with
  `astrona ssh section-030-module-03-playground`.
- **Four raw 1 GB spare disks** (commonly `/dev/vdb`–`/dev/vde`), no RAID
  metadata, no filesystem. Wiped on every boot.
- `mdadm` installed. Passwordless `sudo`.

## Things to try

- `cat /proc/mdstat` (empty), `lsblk`.
- Mirror: `sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/vdb /dev/vdc`
  then watch `cat /proc/mdstat` resync and `sudo mdadm --detail /dev/md0`.
- Put a filesystem on the array: `sudo mkfs.ext4 /dev/md0`, mount it, write a file.
- Try other levels on fresh disks: `--level=0` (stripe, no redundancy),
  `--level=5 --raid-devices=3`, `--level=10 --raid-devices=4`.
- Persist: `sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf`,
  `sudo update-initramfs -u`.
- Tear down: `sudo umount /mnt/raid`, `sudo mdadm --stop /dev/md0`,
  `sudo mdadm --zero-superblock /dev/vdb /dev/vdc`.

## When you're done

```sh
astrona destroy section-030-module-03-playground
```

(`astrona destroy` takes the environment name, not the config path.)
