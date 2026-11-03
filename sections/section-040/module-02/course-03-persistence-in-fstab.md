# Making Swap Persistent in /etc/fstab

Swap areas you switch on by hand disappear at the next launch. The ship's logbook, `/etc/fstab`, brings them back. This part writes the lines, with priorities, and proves them before any reboot.

## The swap lines

A swap line has six fields. For this ship, the two lines look like this:

```text
UUID=<UUID>      none   swap   sw,pri=10   0   0
/swapfile        none   swap   sw,pri=5    0   0
```

- **device**: use `UUID=` for a partition, because device names such as `/dev/vdb1` can change between boots. A swap file is named by its path.
- **mount point**: `none`. Swap is not in the directory tree.
- **type**: `swap`.
- **options**: `sw` plus `pri=` for the priority.
- **dump and pass**: `0` and `0`.

Get the real UUID with `sudo blkid /dev/vdb1`. The value is a placeholder here, because yours is different.

## Writing and applying the lines

The commands below need `/dev/vdb1` and `/swapfile` both formatted as swap. Check with `swapon --show` that they are active with priorities 10 and 5. Each fstab line is a one-line append, and `swapoff -a` followed by `swapon -a` applies the logbook.

<!-- astrona:playground:renew -->

### See it in your playground

Look at the UUID, then append both lines:

```sh
sudo blkid /dev/vdb1
echo "UUID=$(sudo blkid -s UUID -o value /dev/vdb1)  none  swap  sw,pri=10  0  0" | sudo tee -a /etc/fstab
echo "/swapfile  none  swap  sw,pri=5  0  0" | sudo tee -a /etc/fstab
```

Apply the logbook and check:

```sh
sudo swapoff -a
sudo swapon -a
swapon --show
```

Expect something like this:

```text
NAME      TYPE      SIZE USED PRIO
/dev/vdb1 partition 1022M   0B   10
/swapfile file      256M    0B    5
```

`swapon -a` read both lines from `/etc/fstab` and brought the areas up with the priorities you wrote. The configuration now survives a reboot. To undo the edits, run `sudo cp /etc/fstab.orig /etc/fstab`.

## Common pitfalls

> [!WARNING]
> - **Naming the partition `/dev/vdb1` in fstab.** Device names can move between boots, and the wrong disk could become swap. Use `UUID=`.
> - **Writing `pri=` only on the command line.** It is lost at reboot. Put it in the options column.
> - **Editing `/etc/fstab` without a backup.** Keep a copy (the playground has `/etc/fstab.orig`) and run `swapon -a` right after editing to catch mistakes now.
> - **Adding the lines twice.** `swapon -a` then complains the area is in use. Check with `grep swap /etc/fstab`.

## Your mission: Swap Partition Formatting & Priorities

You can now format a raw disk as swap, set priorities and persist both in `/etc/fstab`. The mission asks you to set up a dedicated swap disk with priority 10 next to a swap file with priority 5, and keep both after a reboot.

The mission runs on its own training ship. A playground cannot be paused, so remove it first to free memory. It always starts clean again:

```sh
astrona destroy section-040-module-02-playground
```

Then start the mission and connect to it:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-040/module-02/labs/lab-01
astrona ssh ats-004-lab-042
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-040/module-02/labs/lab-01
```

When the mission is done, remove it and start a fresh playground:

```sh
astrona destroy ats-004-lab-042
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-040/module-02/playground
```
