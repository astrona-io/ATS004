# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the missions in this module. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about keeping an array healthy: reading its state, surviving a failed disk, growing it, getting told about trouble, and moving or reusing its disks.

**From [Reading Health and Handling a Failure](./course-01-health-and-failure.md):**

- `/proc/mdstat` and `mdadm --detail` show `[UUU]` and `State`. A degraded RAID 5 has no redundancy left.
- `mdadm --manage --fail` then `--remove` takes a member out. `--add` brings in a spare and starts the rebuild.

**From [Growing an Array and Getting Notified](./course-02-growth-and-monitoring.md):**

- `mdadm --grow` adds a disk to the array. The filesystem needs its own `resize2fs` or `xfs_growfs`.
- `mdadm --monitor` and `MAILADDR` tell you when a disk fails.

**From [Stopping, Reassembling and Reusing Disks](./course-03-stopping-and-reassembling.md):**

- `umount`, then `mdadm --stop`. `mdadm --assemble --scan` brings the array back from the superblocks.
- `mdadm --zero-superblock` clears a disk that you want to reuse. Never run it on a live member.

## Your missions

You proved the skills in graded missions, right after the part that taught them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [RAID Failure, Replacement & Rebuild Lab](./labs/lab-01/README.md) | Reading Health and Handling a Failure | fail, remove and replace a disk and watch the rebuild |
| [RAID Grow & Failure Monitoring Lab](./labs/lab-02/README.md) | Growing an Array and Getting Notified | grow an array onto a new disk |
| [RAID Stop, Reassemble and Wipe Lab](./labs/lab-03/README.md) | Stopping, Reassembling and Reusing Disks | stop an array, assemble it from named disks and clear an old label with `--zero-superblock` |

If you skipped one, go back to it now. They are short, and the exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. What does `[3/2] [U_U]` mean in `/proc/mdstat`?</summary>

Three members are expected, two are present, and the middle one is missing. The array is degraded.
</details>

<details>
<summary>2. Why is a degraded RAID 5 urgent?</summary>

It has no redundancy left. A second failure loses the data.
</details>

<details>
<summary>3. What do you do after `mdadm --grow` adds a disk?</summary>

Extend the filesystem with `resize2fs` or `xfs_growfs`. The array and the filesystem grow separately.
</details>

<details>
<summary>4. What must you do before `mdadm --stop /dev/md0`?</summary>

Unmount the filesystem and stop anything that uses the array.
</details>

<details>
<summary>5. When is `--zero-superblock` safe?</summary>

Only on a disk that is not part of a running array and that you no longer need.
</details>

## Clean up the playground

Land your training ship before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-030-module-04-playground
```

If `astrona list` also showed a mission, remove it the same way:

```sh
astrona destroy ats-004-lab-034
astrona destroy ats-004-lab-036
```

Then check again:

```sh
astrona list
```

The list should no longer show the playground or the missions from this module. You can start the playground again at any time with the `astrona run` command from the end of a mission; it always starts clean, so nothing you broke carries over.

<!-- astrona:playground:destroy -->
