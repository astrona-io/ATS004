# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about finding out where the space in a cargo hold went: reading the hatch gauge with `df` and weighing the crates with `du`.

**From [df vs du, and Reading du at a Sensible Depth](./course-01-df-vs-du-depth-and-units.md):**

- `df` reads the filesystem's own counters. `du` walks the directory tree.
- `du -h -d 1 <dir> | sort -hr` gives a readable, largest-first list.
- `rm` removes a name. The blocks stay while any process holds the file open.

**From [Staying on One Filesystem & Allocated vs Apparent Size](./course-02-one-filesystem-and-apparent-size.md):**

- `du -x` stops at every mount point by comparing device IDs.
- By default `du` counts allocated blocks. `--apparent-size` counts the length in the inode.
- A sparse file has a large apparent size and almost no allocated blocks.

**From [When df and du Disagree](./course-03-when-df-and-du-disagree.md):**

- `lsof +L1` finds deleted files that a process still holds open.
- Reserved blocks, metadata and files hidden under a mount also make `df` larger than `du`.

## Your missions

You proved the skill in a graded mission, right after the part that taught it:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Directory Capacity Profiling (du -xh) Lab](./labs/lab-01/README.md) | Staying on One Filesystem & Allocated vs Apparent Size | profile `/var/log` at depth one on the root filesystem only and record the largest subdirectory |

If you skipped it, go back to it now. It is short, and the exam asks for exactly this skill.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. <code>df</code> shows the root filesystem at 95%, but <code>du -x /</code> adds up to 60%. What do you check first?</summary>

Run `sudo lsof +L1`. A deleted file that a process still holds open uses blocks but has no name for `du` to find.
</details>

<details>
<summary>2. Why does <code>sort -r</code> put <code>9M</code> above <code>10G</code>?</summary>

It compares text, not sizes. `sort -hr` understands the unit letters.
</details>

<details>
<summary>3. Which option keeps <code>du</code> from entering <code>/proc</code> and network mounts?</summary>

`-x` (`--one-file-system`). It compares the device ID of each entry with the starting one and does not cross a different one.
</details>

<details>
<summary>4. A 512M file shows almost 0 in <code>du -h</code> but 512M in <code>ls -lh</code>. Why?</summary>

It is a sparse file. Most of it was never written, so the filesystem allocated almost no blocks. `ls` shows the length in the inode.
</details>

<details>
<summary>5. You mount a disk on a directory that already held files. Where do the old files go?</summary>

They stay on the lower filesystem, hidden under the mount. They still use its space, and `du` on the mount point does not show them.
</details>

## Clean up the playground

Land your training ship before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-080-module-01-playground
```

If `astrona list` also showed the mission, remove it the same way:

```sh
astrona destroy ats-004-lab-081
```

Then check again:

```sh
astrona list
```

The list should no longer show the playground or the mission from this module. You can start the playground again at any time with the `astrona run` command from the end of the mission; it always starts clean, so nothing you broke carries over.

<!-- astrona:playground:destroy -->
