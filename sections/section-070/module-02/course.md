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

## How this module is organised

1. **[Part 1 — From Device to Process: iotop & pidstat](./course-01-iotop-and-pidstat.md)** — `iotop`'s dependency on kernel task delay accounting (and why it silently reads all zeros without it), and `pidstat -d` as the accounting-source-independent fallback.
2. **[Part 2 — lsof & Closing the Loop](./course-02-lsof-and-closing-the-loop.md)** — finding the exact file a process is hammering with `lsof`, then chaining device → mount → PID → file into one confident diagnosis.

## Learning objectives

After this module you can:

- Read per-process disk read/write rates with `iotop -o` and with `pidstat -d`.
- Explain why `iotop` can show all zeros, which kernel feature it depends on, and how to fix it.
- Explain why `pidstat -d` needs no such tunable — what accounting source it reads instead.
- List the files a process has open with `lsof -p <PID>` and find which are on a given mount.
- Trace a bottleneck end to end: device → mount point → process → file, and state which accounting source backs each step.

## Before you start

You need the previous module's material: I/O wait, and reading `iostat -xz 1` (`%util`, `aqu-sz`, `w_await`).

The linked playground gives you an Ubuntu server VM with `iotop`, `sysstat` (`pidstat`, `iostat`), `lsof`, and `fio` installed, a spare disk mounted at `/mnt/perf`, and `kernel.task_delayacct=1` already set so `iotop` works. A helper `start-io-load` backgrounds a continuous writer to `/mnt/perf/leak.log` and prints its PID; `stop-io-load` ends it. Run the command blocks in both parts in that VM after `astrona ssh section-070-module-02-playground`.
