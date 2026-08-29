# Process-Level Auditing: Identifying the Culprit

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-070/module-02/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-070/module-02/playground
> astrona destroy section-070-module-02-playground
> ```

`iostat` (previous module) tells you *a device* is saturated. It does not tell you *which process* is doing it. This module closes that gap: find the process generating the I/O, find the exact file it is writing, and confirm that file sits on the device `iostat` flagged.

The tools are `iotop` and `pidstat` for per-process I/O rates, and `lsof` for the files a process holds open.

## Learning objectives

After this module you can:

- Read per-process disk read/write rates with `iotop -o` and with `pidstat -d`.
- Explain why `iotop` can show all zeros and how to fix it.
- List the files a process has open with `lsof -p <PID>` and find which are on a given mount.
- Trace a bottleneck end to end: device → mount point → process → file.

## Before you start

You need the previous module's material: I/O wait, and reading `iostat -xz 1` (`%util`, `aqu-sz`, `w_await`).

The linked playground gives you an Ubuntu server VM with `iotop`, `sysstat` (`pidstat`, `iostat`), `lsof`, and `fio` installed, a spare disk mounted at `/mnt/perf`, and `kernel.task_delayacct=1` already set so `iotop` works. A helper `start-io-load` backgrounds a continuous writer to `/mnt/perf/leak.log` and prints its PID; `stop-io-load` ends it. Run the command blocks below in that VM after `astrona ssh section-070-module-02-playground`.

## From device to process

The workflow after `iostat` points at a device: identify the top I/O-consuming process, then identify the file it is hammering, then verify that file lives on the flagged device. Each step narrows from "the disk is busy" to "this process, this file" — enough to act (rotate a log, fix a config, stop a runaway job).

## `iotop`: per-process I/O rates

`iotop` is `top` for disk I/O. Plain `iotop` lists every process, most reading `0.00 B/s`, which buries the one that matters. `iotop -o` shows only processes doing I/O right now. It needs root, and it needs the kernel's **task delay accounting** enabled — on kernels from 5.14 onward that is off by default, and without it `iotop` shows zeros for every process. Enable it with `sysctl -w kernel.task_delayacct=1` (already done in the playground).

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

`pidstat -d <interval>` (from `sysstat`) reports the same per-process read/write rates without needing delay accounting or the `iotop` package. It is the reliable fallback when `iotop` shows zeros or is not installed.

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
> `kB_wr/s` for PID `2451` matches what `iotop` reported. `pidstat -d` needs no root for your own processes and no kernel tunable — reach for it first when `iotop` is uncooperative.

## `lsof`: which file the process is hitting

A PID is not enough when the process is a database or a log shipper — you need the specific file. `lsof -p <PID>` lists everything that process has open: libraries, sockets, and regular files. Filter the `NAME` column for the saturated mount point.

> [!TIP]
> **Try it — the exact file**
>
> ```sh
> sudo lsof -p 2451 | grep /mnt/perf
> sudo lsof /mnt/perf/leak.log
> ```
>
> Expect something like:
>
> ```text
> fio     2451 ubuntu    5u   REG  254,16  536870912  12  /mnt/perf/leak.log
>
> COMMAND   PID   USER   FD   TYPE DEVICE  SIZE/OFF NODE NAME
> fio      2451 ubuntu    5u   REG  254,16 536870912   12 /mnt/perf/leak.log
> ```
>
> `lsof -p` shows PID `2451` holds `/mnt/perf/leak.log` open for writing (`5u` — descriptor 5, read/write). Coming from the other direction, `lsof <path>` lists every process using that file. Either way you now have process *and* file.

## Closing the loop: device → mount → PID → file

Put the pieces together into a chain you can state with confidence.

> [!TIP]
> **Try it — the full trace**
>
> ```sh
> iostat -xz 1 2
> findmnt --noheadings --output SOURCE,TARGET /mnt/perf
> pidstat -d 1 1
> sudo lsof /mnt/perf/leak.log
> stop-io-load
> ```
>
> Expect something like:
>
> ```text
> Device   w/s    wkB/s  w_await  aqu-sz  %util
> vdb    210.0   215000     4.20    1.90   99.5      <- device vdb is saturated
>
> /dev/vdb  /mnt/perf                                <- vdb is mounted at /mnt/perf
>
>    UID   PID   kB_wr/s  Command
>   1000  2451  215000.00  fio                       <- PID 2451 is the writer
>
> fio 2451 ubuntu  5u  REG  254,16  ...  /mnt/perf/leak.log   <- writing this file
> ```
>
> The four commands form the sentence: *device `vdb` is at 100% util; `vdb` is mounted at `/mnt/perf`; PID 2451 is writing ~210 MB/s; the file is `/mnt/perf/leak.log`.* That is a complete diagnosis. `stop-io-load` clears it.

> [!WARNING]
> **Common pitfalls**
>
> - **`iotop` shows all zeros.** Task delay accounting is off (default on kernels ≥ 5.14) or you are not root. `sudo sysctl -w kernel.task_delayacct=1`, run with `sudo`, or use `pidstat -d`.
> - **Confusing TID with PID.** `iotop` shows thread IDs by default; a multithreaded process appears as several rows. Add `-P` to aggregate by process, and cross-check the number with `ps`.
> - **`lsof` missing entries.** Without `sudo` you only see your own processes' files. Run it as root to inspect another user's or a system service's handles.
> - **Acting before tracing.** Killing the top `iotop` process without checking the file can take down the wrong thing. Confirm the device → mount → file chain first, then decide.
> - **A file that `lsof` shows as `(deleted)`.** A process can hold a deleted file open and keep writing to it — space is not freed and it will not appear in `ls`. `lsof` still shows it, marked `(deleted)`; the fix is to restart or signal the process.
