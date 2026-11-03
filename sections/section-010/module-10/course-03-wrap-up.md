# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about Btrfs: a filesystem that keeps one pool of space, cuts named shelves from it, and photographs them cheaply.

**From [Creating Btrfs and Subvolumes](./course-01-creating-btrfs-and-subvolumes.md):**

- Btrfs is copy-on-write: it writes new data to a free spot and keeps the old data until nothing needs it.
- `mkfs.btrfs -L NAME device` builds the filesystem. `btrfs filesystem show`, `df` and `usage` read its state.
- A subvolume is a named shelf. `btrfs subvolume create` makes one and `btrfs subvolume list` lists them.
- `mount -o subvol=NAME` docks one subvolume. In `/etc/fstab` the same option, `subvol=NAME`, goes in the options field with `UUID=` as the device.

**From [Snapshots and Resizing](./course-02-snapshots-and-resizing.md):**

- `btrfs subvolume snapshot -r` makes a read-only snapshot. Without `-r` it is writable. A snapshot costs almost no space at first.
- `btrfs subvolume delete` removes a subvolume or snapshot.
- `btrfs filesystem resize` changes the size of a mounted filesystem. It takes a change such as `-200M`, or `max`, and a mount point.
- `df` is unreliable on Btrfs. `btrfs filesystem usage` shows the real split.

## Your missions

You proved the skill in a graded mission, right after the part that taught it:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Btrfs Subvolume and Snapshot](./labs/lab-01/README.md) | Snapshots and Resizing | format a disk as Btrfs with a label, mount a subvolume persistently by UUID, and take a read-only snapshot |

If you skipped it, go back to it now. It is short, and the exam asks for exactly this skill.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. Why is a Btrfs snapshot almost free when you take it?</summary>

Because of copy-on-write. The snapshot and the original point at the same data. Only changes made afterwards need new space.
</details>

<details>
<summary>2. Which option mounts only the subvolume <code>data</code> instead of the whole filesystem?</summary>

`-o subvol=data` on the `mount` command, or `subvol=data` in the options field of the `/etc/fstab` line.
</details>

<details>
<summary>3. You run <code>btrfs filesystem resize -200M /dev/vdb</code> and it fails. What is wrong?</summary>

The command takes a mount point, not a device. Mount the filesystem and give it the mount path.
</details>

<details>
<summary>4. <code>rm -r</code> fails on a read-only snapshot. How do you remove it?</summary>

Run `sudo btrfs subvolume delete` on its path.
</details>

<details>
<summary>5. Why is <code>df</code> a poor way to check free space on Btrfs?</summary>

It prints one total and one free number. It does not see the split between data and metadata, or the space that snapshots share. Use `btrfs filesystem usage`.
</details>

## Clean up the playground

Land your training ship before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-010-module-10-playground
```

If `astrona list` also showed the mission, remove it the same way:

```sh
astrona destroy ats-004-lab-091
```

Then check again:

```sh
astrona list
```

The list should no longer show the playground or the mission from this module. You can start the playground again at any time with the `astrona run` command from the end of the mission; it always starts clean, so nothing you broke carries over.

<!-- astrona:playground:destroy -->
