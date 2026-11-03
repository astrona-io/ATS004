# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module built a software RAID array from the first idea to a mount that survives a reboot.

**From [RAID Levels](./course-01-raid-levels.md):**

- RAID 0 has no safety. RAID 1 mirrors. RAID 5 keeps one disk of parity (N minus 1 usable). RAID 10 mirrors pairs and stripes them.
- Each minimum disk count follows from the layout: parity needs a third disk, a stripe of mirrors needs four.

**From [Creating & Persisting an Array](./course-02-creating-and-persisting.md):**

- `mdadm --create /dev/md0 --level=... --raid-devices=N` builds the array and starts a resync.
- Format `/dev/md0`, never a member disk.
- `mdadm --detail --scan` into `/etc/mdadm/mdadm.conf`, then `update-initramfs -u`, makes the array assemble at boot. The fstab line uses the filesystem UUID.

**From [Reading an Array Closely](./course-03-reading-an-array.md):**

- `/proc/mdstat` is the quick view, `--detail` is the full array, `--examine` is one member's superblock.
- The `Events` counter shows a stale member. `[UUU]` shows who is up.

## Your missions

You proved the skills in graded missions, right after the part that taught them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [RAID 5 Array Creation & Persistence Lab](./labs/lab-01/README.md) | Creating & Persisting an Array | create a three-disk RAID 5, mount it, and make it persistent |

If you skipped one, go back to it now. They are short, and the exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. How much usable space do three 1 GB disks give in RAID 5?</summary>

About 2 GB. One disk's worth of space holds parity.
</details>

<details>
<summary>2. Why is RAID not a backup?</summary>

It survives a failed disk only. A deleted file is deleted on every disk.
</details>

<details>
<summary>3. Which two steps make an array assemble at boot?</summary>

An `ARRAY` line in `/etc/mdadm/mdadm.conf`, then `update-initramfs -u`.
</details>

<details>
<summary>4. Why use the filesystem UUID in `/etc/fstab` and not `/dev/md0`?</summary>

The array can come up as `/dev/md127` after a reboot. The UUID of the filesystem does not change.
</details>

<details>
<summary>5. What does a lower `Events` value on one member tell you?</summary>

That member missed writes and is stale. It must be re-synced.
</details>

## Clean up the playground

Land your training ship before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-030-module-03-playground
```

If `astrona list` also showed a mission, remove it the same way:

```sh
astrona destroy ats-004-lab-033
```

Then check again:

```sh
astrona list
```

The list should no longer show the playground or the missions from this module. You can start the playground again at any time with the `astrona run` command from the end of a mission; it always starts clean, so nothing you broke carries over.
