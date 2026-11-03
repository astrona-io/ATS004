# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about a hold built only for overflow: the swap partition, its priority, and its place in the logbook.

**From [Partition Versus File, and Creating the Partition](./course-01-partition-vs-file-and-creating-it.md):**

- A swap partition skips the filesystem driver that a swap file passes through.
- `parted` with `linux-swap` sets the partition type only. `mkswap` writes the header.

**From [Formatting, Activating and Priorities](./course-02-formatting-activating-and-priorities.md):**

- `mkswap` then `swapon` turns a raw partition into swap.
- Equal priorities share the work in turns. A higher priority fills first and completely.

**From [Making Swap Persistent in /etc/fstab](./course-03-persistence-in-fstab.md):**

- A swap line is `UUID=<UUID>  none  swap  sw,pri=10  0  0`, and a swap file is named by its path.
- `swapoff -a` then `swapon -a` proves the logbook before a reboot.

**From [Labels, the Swap Table and Fixing a Swap That Will Not Start](./course-04-labels-swap-table-and-troubleshooting.md):**

- `/proc/swaps`, `swapon --show` and `blkid` show what is active and what is on the device.
- `swaplabel` changes a label and keeps the UUID. `swapon -a` reports a bad fstab line.

## Your missions

You proved the skill in a graded mission, right after the part that taught it:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Swap Partition Formatting & Priorities](./labs/lab-01/README.md) | Making Swap Persistent in /etc/fstab | format a raw disk as swap, give it priority 10 above a swap file at priority 5, and persist both in `/etc/fstab` |

If you skipped it, go back to it now. It is short, and the exam asks for exactly this skill.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. Why is a swap partition faster than a swap file?</summary>

Pages go straight to raw blocks. A swap file adds the filesystem driver, with its extent lookup and journal.
</details>

<details>
<summary>2. A fast partition and a slow file both have the default priority. What does the kernel do?</summary>

It writes to them in turns, so the fast partition is slowed to the file's pace. Set a higher `pri=` on the fast one.
</details>

<details>
<summary>3. Why does the fstab line for a swap partition use <code>UUID=</code>?</summary>

Device names such as `/dev/vdb1` can change between boots. The UUID stays with the swap header.
</details>

<details>
<summary>4. You ran <code>swapon -p 10 /dev/vdb1</code> and rebooted. Is the priority still 10?</summary>

No. Put `pri=10` in the options column of the `/etc/fstab` line.
</details>

<details>
<summary>5. How do you add a label to a swap area and keep its UUID?</summary>

Switch it off and run `sudo swaplabel -L <label> <device>`. Running `mkswap` again would create a new UUID.
</details>

## Clean up the playground

Land your training ship before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-040-module-02-playground
```

If `astrona list` also showed the mission, remove it the same way:

```sh
astrona destroy ats-004-lab-042
```

Then check again:

```sh
astrona list
```

The list should no longer show the playground or the mission from this module. You can start the playground again at any time with the `astrona run` command from the end of the mission. It always starts clean.
