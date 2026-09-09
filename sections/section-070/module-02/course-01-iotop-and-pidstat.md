# Part 1 — From Device to Process: iotop & pidstat

> Prerequisite: [Module landing page](./course.md). Next: [Part 2 — lsof & Closing the Loop](./course-02-lsof-and-closing-the-loop.md).

`iostat` (previous module) tells you *a device* is saturated. It does not tell you *which process* is doing it. This part covers the two tools that turn "the disk is busy" into "this process is the one hammering it": `iotop`, which needs a specific kernel feature to work at all, and `pidstat -d`, which does not.

## From device to process

The workflow after `iostat` points at a device: identify the top I/O-consuming process, then identify the file it is hammering, then verify that file lives on the flagged device. Each step narrows from "the disk is busy" to "this process, this file" — enough to act (rotate a log, fix a config, stop a runaway job).

## `iotop`: per-process I/O rates

`iotop` is `top` for disk I/O, but it is not reading the same kind of data `top` reads for CPU. CPU accounting is cheap and has been built into the scheduler forever; per-process *disk* I/O accounting is not automatic — the kernel has to be told to track it. That tracking is **task delay accounting** (`TASKSTATS`): a per-task record of time spent blocked on I/O, swapping, and a few other resources, exposed through a netlink interface that tools like `iotop` read. On kernels from 5.14 onward, delay accounting is off by default for cost reasons; without it, every row in `iotop` reads `0.00 B/s` regardless of what a process is actually doing, because there is nothing underneath supplying the numbers. Enable it with `sysctl -w kernel.task_delayacct=1` (already done in the playground) — this is the same runtime-vs-persistent sysctl mechanism from Section 060, and the same rule applies: it will not survive a reboot unless it is also written to `/etc/sysctl.d/`.

Plain `iotop` lists every process, most reading `0.00 B/s`, which buries the one that matters. `iotop -o` shows only processes doing I/O right now. It needs root — reading another user's per-task delay-accounting data is a privileged operation, the same reasoning that gates `lsof` on other users' open files in Part 2.

`-b` runs `iotop` in batch mode (plain lines, no full-screen UI), and `-n <count>` stops after that many samples — the form to use in a script or a one-off check.

> [!TIP]
> **Try it — find the writer**
>
> ```sh
> start-io-load
> sudo iotop -o -b -n 3 -d 1
> ```
>
> Expect something like:
>
> ```text
> write load started, PID 2451  (file: /mnt/perf/leak.log)
>
> Total DISK READ:   0.00 B/s | Total DISK WRITE: 210.00 M/s
>    TID  PRIO  USER   DISK READ  DISK WRITE  COMMAND
>   2451  be/4  ubuntu   0.00 B/s  210.00 M/s  fio --name=leak ...
> ```
>
> Only the `fio` writer shows up (that is what `-o` filters to), with its write rate and command line. That PID/TID is the lead to chase. If every row read `0.00 B/s`, delay accounting would be off.

## `pidstat -d`: the dependency-free alternative

`pidstat -d <interval>` (from `sysstat`) reports the same per-process read/write rates from a different source: the kernel's per-process I/O accounting fields in `/proc/<PID>/io` (`read_bytes`/`write_bytes`), which — unlike task delay accounting — are always on, no sysctl required. That is the entire reason it is the reliable fallback: it needs no root for your own processes and no kernel tunable, because the counters it reads were never gated behind one.

> [!TIP]
> **Try it — the same picture from pidstat**
>
> ```sh
> pidstat -d 1 3
> ```
>
> Expect something like:
>
> ```text
> #      Time   UID       PID   kB_rd/s   kB_wr/s kB_ccwr/s  Command
>    12:00:01  1000      2451      0.00 215000.00      0.00  fio
> ```
>
> `kB_wr/s` for PID `2451` matches what `iotop` reported. `pidstat -d` reach for it first when `iotop` is uncooperative — its data source doesn't depend on a tunable someone might have left off.

> *`iotop` and `pidstat -d` measure the same thing from two different kernel accounting sources — one gated behind a sysctl, one always on — which is exactly why the second is the fallback for the first.*

## Reference

- `man iotop` — `-o`, `-b`, `-P` (aggregate by process instead of thread), and the columns beyond DISK READ/WRITE.
- `man pidstat` — `-d` plus the other resource views (`-u` CPU, `-r` memory) the same tool provides.
