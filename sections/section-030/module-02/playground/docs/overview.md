# Overview: Advanced LVM Operations (Playground)

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 server VM, reached with `astrona ssh section-030-module-02-playground`.
- `lvm2` installed, passwordless `sudo`.
- **A pre-built LVM stack:**
  - Volume group `vgdata` spanning two 1 GB disks.
  - Logical volume `applv` (400 MiB, ext4), all its extents on the **first**
    disk, mounted at `/mnt/applv` with sample files.
  - A **third disk left raw** (not a PV) to act as the healthy replacement.
- The kernel names of the three disks are written to `/etc/playground-disks`
  (`source_disk`, `second_disk`, `spare_disk`) so you never have to guess the
  `vdb`/`vdc`/`vdd` order. `cat /etc/playground-disks` to see them.

## Things to try

- Survey: `sudo pvs`, `sudo vgs`, `sudo lvs -o +devices`, `df -h /mnt/applv`.
- Add the spare: `sudo pvcreate <spare>`, `sudo vgextend vgdata <spare>`.
- Evacuate the first disk while `applv` stays mounted: `sudo pvmove <source>`,
  then re-check `lvs -o +devices` and that `/mnt/applv/data.txt` is intact.
- Retire it: `sudo vgreduce vgdata <source>`, `sudo pvremove <source>`.
- Grow the volume live: `sudo lvextend -L +200M /dev/vgdata/applv`, then
  `sudo resize2fs /dev/vgdata/applv`, watching `df -h` before and after.

## When you're done

```sh
astrona destroy section-030-module-02-playground
```

(`astrona destroy` takes the environment name, not the config path.)
