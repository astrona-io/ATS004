# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about the spare cargo hold of a ship: swap, built from an ordinary file.

**From [What Swap Is and Checking What You Have](./course-01-what-swap-is-and-checking-it.md):**

- Swap is a slower tier the kernel manages all the time. `kswapd` moves cold pages out before RAM is truly empty.
- `free -h` and `swapon --show` show the current picture. A little swap in use on an idle ship is normal.

**From [Allocating, Activating and Deactivating a Swap File](./course-02-allocating-activating-deactivating.md):**

- `fallocate` reserves real blocks fast. A sparse file is a poor swap file.
- `chmod 600` keeps swapped-out memory away from other users.
- `mkswap` writes a header, not a filesystem. `swapon` reads it, and `swapoff` copies pages back to RAM first.

**From [Making a Swap File Survive a Reboot](./course-03-persisting-a-swap-file.md):**

- The line `/swapfile  none  swap  sw  0  0` in `/etc/fstab` brings the swap back at launch.
- `swapoff -a` then `swapon -a` proves the line without a reboot.

**From [Tuning Swap Behaviour with swappiness](./course-04-swappiness-tuning.md):**

- `vm.swappiness` sets how eagerly the kernel uses swap. The default is 60.
- `sysctl vm.swappiness=10` lasts until reboot. A file in `/etc/sysctl.d/` keeps it.

## Your missions

You proved the skill in a graded mission, right after the part that taught it:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Swap File Allocation & Security](./labs/lab-01/README.md) | Making a Swap File Survive a Reboot | allocate, secure, format and activate `/swapfile`, and persist it in `/etc/fstab` |

If you skipped it, go back to it now. It is short, and the exam asks for exactly this skill.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. An idle machine with plenty of free RAM shows a little swap in use. Is something wrong?</summary>

No. `kswapd` moved some idle pages out earlier, and nothing needed them back.
</details>

<details>
<summary>2. Why must a swap file have mode 600?</summary>

The kernel writes raw memory into it, and that memory can hold passwords and keys. Mode 600 lets only `root` read it.
</details>

<details>
<summary>3. What does <code>mkswap</code> write?</summary>

A swap header with the signature `SWAPSPACE2`, a UUID, the page size and a map of usable pages. It does not build a filesystem.
</details>

<details>
<summary>4. How do you prove an fstab swap line works without rebooting?</summary>

Run `sudo swapoff -a`, then `sudo swapon -a`, then `swapon --show`. The area must be listed again.
</details>

<details>
<summary>5. You run <code>sudo sysctl vm.swappiness=10</code>. Will it still be 10 after a reboot?</summary>

No. Write `vm.swappiness = 10` into a file in `/etc/sysctl.d/` and run `sudo sysctl --system`.
</details>

## Clean up the playground

Land your training ship before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-040-module-01-playground
```

If `astrona list` also showed the mission, remove it the same way:

```sh
astrona destroy ats-004-lab-041
```

Then check again:

```sh
astrona list
```

The list should no longer show the playground or the mission from this module. You can start the playground again at any time with the `astrona run` command from the end of the mission. It always starts clean.
