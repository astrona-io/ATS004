# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the missions in this module. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module built the pool from the bottom up: disks into PVs, PVs into a VG, and the VG into volumes that you format and mount.

**From [Why LVM & the Three-Layer Model](./course-01-why-lvm-and-the-stack.md):**

- A plain partition is welded to one disk. LVM adds a layer so volumes can grow and move.
- The stack is PV (a labelled disk), VG (the pool), LV (what you format and mount).
- An LV is a list of extents that device-mapper replays into one block device.

**From [Physical Volumes & Volume Groups](./course-02-pv-and-vg.md):**

- `pvcreate` writes only a label and a metadata area. `pvs` and `pvdisplay` show the result.
- `vgcreate` pools PVs and cuts them into 4 MiB extents. `vgs` and `vgdisplay` show size and extent count.

**From [Logical Volumes](./course-03-logical-volumes.md):**

- `lvcreate -n name -L size vg` reserves extents. You still have to run `mkfs` and `mount`.
- `lvs -o +devices` shows which disks hold the extents. A big LV spans disks without a warning.

**From [How an LV Becomes a Device, and Stays Mounted](./course-04-device-mapper-and-persistent-mounts.md):**

- `lvdisplay -m`, `lvs -o +seg_pe_ranges` and `dmsetup table` show the extent list at three levels.
- `/dev/<vg>/<lv>` and `/dev/mapper/<vg>-<lv>` are the same device. Dashes are doubled in the second name.
- A mount survives a reboot only with an `/etc/fstab` line. Test with `findmnt --verify` and `mount -a`.

## Your missions

You proved the skills in graded missions, right after the part that taught them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [LVM Fundamentals: PV, VG, and LV Allocation Lab](./labs/lab-01/README.md) | Logical Volumes | build a VG, carve a 500M LV, format it and mount it |
| [LVM Fundamentals: Pooling PVs Across Disks Lab](./labs/lab-02/README.md) | Logical Volumes | pool two disks and carve an LV bigger than either one |

If you skipped one, go back to it now. They are short, and the exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. What does `pvcreate` write to a disk?</summary>

A small LVM label and a metadata area at the start of the disk. It does not format the rest.
</details>

<details>
<summary>2. What is the default extent size, and why does it matter?</summary>

4 MiB. Every LV size is a whole number of extents, so sizes are rounded up to the next 4 MiB.
</details>

<details>
<summary>3. You ask for an LV bigger than any one disk in the pool. What happens?</summary>

LVM spans disks silently. `lvs -o +devices` shows which disks hold the extents.
</details>

<details>
<summary>4. What is the difference between `/dev/vg/lv` and `/dev/mapper/vg-lv`?</summary>

None. They are two names for the same device-mapper device. Dashes in the names are doubled in the mapper name.
</details>

<details>
<summary>5. Which two commands do you run before you reboot to test a new fstab line?</summary>

`sudo findmnt --verify` and `sudo mount -a`.
</details>

## Clean up the playground

Land your training ship before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-030-module-01-playground
```

If `astrona list` also showed a mission, remove it the same way:

```sh
astrona destroy ats-004-lab-031
astrona destroy ats-004-lab-037
```

Then check again:

```sh
astrona list
```

The list should no longer show the playground or the missions from this module. You can start the playground again at any time with the `astrona run` command from the end of a mission; it always starts clean, so nothing you broke carries over.

<!-- astrona:playground:destroy -->
