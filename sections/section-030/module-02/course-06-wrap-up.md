# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the missions in this module. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module changed a pool while it was in use: moving data off a disk, removing the disk, and growing or shrinking volumes.

**From [The LVM Stack, Recapped & Reading State](./course-01-stack-and-state.md):**

- A volume is a list of extents. `pvs`, `vgs` and `lvs -o +devices` show the list.
- Match disks by serial, not by `vdX` letter.

**From [Live Migration: pvmove](./course-02-pvmove-migration.md):**

- `vgextend` gives the pool a place to move to. `pvmove` moves one extent at a time and is safe to resume.
- `lvs -o +devices` proves the old disk is empty.

**From [vgreduce, and Growing/Shrinking a Volume](./course-03-vgreduce-lvextend.md):**

- `vgreduce` refuses a disk that still holds extents. `pvremove` then wipes its label.
- Grow: `lvextend -L +size`, then the filesystem. Shrink ext4: `e2fsck -f`, `resize2fs`, then `lvreduce`. XFS cannot shrink.

**From [Removing Any PV, and Physical Disk Safety](./course-04-removing-any-pv-and-safety.md):**

- The same three commands work for any number of disks. Check free space on the other PVs first.
- `pvremove` is not the same as safe to unplug on real hardware.

**From [Growing in One Command](./course-05-growing-in-one-command.md):**

- `lvextend -r` grows the volume and the filesystem together.
- `-l +100%FREE` hands the rest of the pool to the volume. XFS grows with `xfs_growfs` on the mount point.

## Your missions

You proved the skills in graded missions, right after the part that taught them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Optional guided migration (032)](./labs/lab-01/README.md) | vgreduce, and Growing/Shrinking a Volume | move extents with `pvmove`, then run `vgreduce` and `pvremove` |
| [LVM Live Grow & Safe Shrink Lab](./labs/lab-02/README.md) | vgreduce, and Growing/Shrinking a Volume | grow a volume to 500M and shrink it to 350M with the data intact |
| [LVM: vgextend a Live Pool, Then Evacuate a Disk Lab](./labs/lab-03/README.md) | vgreduce, and Growing/Shrinking a Volume | extend a live pool and evacuate a disk |
| [LVM: Growing an XFS Volume Lab](./labs/lab-05/README.md) | vgreduce, and Growing/Shrinking a Volume | grow an XFS volume with `lvextend` and `xfs_growfs` |
| [Optional advanced migration (039)](./labs/lab-04/README.md) | Removing Any PV, and Physical Disk Safety | remove one disk out of three with mixed extents |
| [Persistent LVM Mount and One-Command Grow Lab](./labs/lab-06/README.md) | Growing in One Command | write an `/etc/fstab` line for a volume and grow it with `lvextend -r` |

Lab 038 is the main migration exercise. Lab 032 is optional guided practice with spare capacity already available; lab 039 is an optional advanced variation with extents distributed across three disks.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. Why does `df` not change after `lvextend` alone?</summary>

The filesystem keeps its own size in its superblock. Run `resize2fs` (ext4) or `xfs_growfs` (XFS), or use `lvextend -r`.
</details>

<details>
<summary>2. What is the difference between `-L +200M` and `-L 200M`?</summary>

`+200M` adds 200 MiB. `200M` sets the size to 200 MiB, which is a shrink on a bigger volume.
</details>

<details>
<summary>3. Why does `vgreduce` refuse a disk?</summary>

The disk still holds extents. Run `pvmove` first so that it holds none.
</details>

<details>
<summary>4. In what order do you shrink an ext4 volume?</summary>

`e2fsck -f`, then `resize2fs`, then `lvreduce`. The other order destroys data.
</details>

<details>
<summary>5. Which tool grows XFS, and what does it take as an argument?</summary>

`xfs_growfs`, with the mount point. XFS cannot shrink.
</details>

## Clean up the playground

Land your training ship before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-030-module-02-playground
```

If `astrona list` also showed a mission, remove it the same way:

```sh
astrona destroy ats-004-lab-032
astrona destroy ats-004-lab-035
astrona destroy ats-004-lab-038
astrona destroy ats-004-lab-086
astrona destroy ats-004-lab-039
```

Then check again:

```sh
astrona list
```

The list should no longer show the playground or the missions from this module. You can start the playground again at any time with the `astrona run` command from the end of a mission; it always starts clean, so nothing you broke carries over.

<!-- astrona:playground:destroy -->
