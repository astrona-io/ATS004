# Limits, Status and Storage Counters

A crew member can only hold so many lines open, and the whole ship has a cap too. This part reads those limits, then two more screens that storage work needs: the process status screen and the raw disk counters.

## The open-file limits

When a process fails with "Too many open files", one of two caps was hit. This section shows both and where to read them.

### Per-process and system-wide caps

Each process has its own cap on open descriptors. It is the "Max open files" line in `/proc/<PID>/limits`. The kernel also has one cap for the whole ship: `/proc/sys/fs/file-max`. The file `/proc/sys/fs/file-nr` shows the current use. Its first number is the descriptors allocated now. The last number is the same cap as `file-max`.

<!-- astrona:playground:renew -->

### See it in your playground

Read the per-process cap of the demo process, then the system-wide numbers. Run `start-demo-proc` first if you stopped it, and set `PID` to its new number.

```sh
grep 'Max open files' /proc/$PID/limits
cat /proc/sys/fs/file-max
cat /proc/sys/fs/file-nr
```

The first command prints one line with a soft limit and a hard limit. The second prints the system-wide cap as a single number. The third prints three numbers separated by tabs. Your values depend on your ship, so compare them with what you see, not with fixed numbers.

## The process status screen

`/proc/<PID>/status` is a short, readable report about one process. This section lists the lines you need most.

### Lines worth knowing

- `Name` is the program name.
- `State` is the process state. `S` means sleeping, `R` running and `D` waiting on I/O and unable to be interrupted.
- `Pid` and `PPid` are the badge number and the parent's badge number.
- `VmRSS` is the memory the process holds in RAM right now.
- `FDSize` is the size of the descriptor table, not the count of used slots.

### See it in your playground

Print only those lines for the demo process.

```sh
grep -E '^(Name|State|Pid|PPid|VmRSS|FDSize):' /proc/$PID/status
```

The output has one line per field, in the order the kernel writes them. The `State` of an idle `tail` process is normally `S (sleeping)`.

## Storage counters: `/proc/diskstats` and `/proc/mounts`

Two more generated files matter for storage. `/proc/diskstats` holds the running totals for every block device. `/proc/mounts` lists every mounted filesystem. This section shows the fields you can read by eye.

### Reading one line

Each line of `/proc/diskstats` starts with the device's major number, minor number and name. The numbers after the name are counters that only grow since boot. They include reads completed, sectors read, writes completed and sectors written. Tools such as `iostat` read this file twice and subtract to get rates.

Each line of `/proc/mounts` has the device, the mount point, the filesystem type and the options. The kernel generates it from its live mount list, so it cannot drift from reality.

### See it in your playground

Look at the counters for the root disk and find the root mount.

```sh
grep -w vda /proc/diskstats
grep ' / ' /proc/mounts
```

The first line starts with a major number, then `0 vda`, then the counters. The second line shows the root device, the mount point `/`, the type and the options. Run the first command twice a few seconds apart. The counters never go down.

## Your mission: proc System Limits & File Descriptors Auditing Lab

You can now find a process, count its open descriptors and read the system-wide open-file limit. The mission asks you to count the descriptors of `systemd-journald` and record the kernel's file limit.

The mission runs on its own training ship. A playground cannot be paused, so remove it first to free memory. It always starts clean again:

```sh
astrona destroy section-060-module-01-playground
```

Then start the mission and connect to it:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-060/module-01/labs/lab-01
astrona ssh ats-004-lab-061
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-060/module-01/labs/lab-01
```

When the mission is done, remove it and start a fresh playground:

```sh
astrona destroy ats-004-lab-061
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-060/module-01/playground
```

## Common pitfalls

> [!WARNING]
> - **Mixing up the two caps.** `/proc/<PID>/limits` is per process. `/proc/sys/fs/file-max` is for the whole ship. A process can hit its own cap long before the system cap.
> - **Reading `FDSize` as the count.** It is the table size. Count the entries in `/proc/<PID>/fd/` for real use.
> - **Using other users' processes without `sudo`.** `fd/` and some status files of another user's process are not readable. Run the command with `sudo`.
> - **Expecting `diskstats` to show rates.** The numbers are totals since boot. A rate needs two reads and a subtraction.
