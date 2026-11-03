# Process-Level Auditing: Identifying the Culprit

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-070/module-02/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-070/module-02/playground
> astrona destroy section-070-module-02-playground
> ```

Astronaut, `iostat` tells you that one cargo hold is saturated. It does not tell you which crew member is hammering it. This module closes that gap. You find the process that makes the I/O, find the exact file it writes, and prove that the file sits on the hold `iostat` flagged.

The tools are `iotop` and `pidstat` for the I/O of each process, and `lsof` for the files a process holds open.

## Learning objectives

After this module you can:

- Read per-process disk read and write rates with `iotop -o` and with `pidstat -d`.
- Explain why `iotop` can show all zeros, which kernel feature it depends on, and how to fix it.
- Read `/proc/<PID>/io` and explain the difference between `rchar` and `read_bytes`.
- Explain why `pidstat -d` needs no tunable, and what accounting source it reads instead.
- List the files a process has open with `lsof -p <PID>`, and list the users of a file or a directory with `lsof <path>` and `lsof +D <dir>`.
- Find deleted files that are still held open, and say why they still use space.
- Trace a bottleneck end to end: device, mount point, process, file.

## Before you start

Every mission starts with a pre-flight check. Make sure you know the basics below, and know what waits for you in your training ship.

### What you should already know

- How to read `iostat -xz 1` and what `%util`, `aqu-sz` and `w_await` mean.
- That `/proc/<PID>/` is a live view of one process.

### What is in your playground

Your playground is one training spaceship: an Ubuntu 24.04 virtual machine with passwordless `sudo`.

- `iotop`, `sysstat` (`pidstat` and `iostat`), `lsof` and `fio` are installed.
- A spare disk is mounted at `/mnt/perf`.
- `kernel.task_delayacct=1` is already set, so `iotop` shows real numbers.
- The helper `start-io-load` starts a continuous writer to `/mnt/perf/leak.log` and prints its PID. `stop-io-load` ends it and removes the file.

Start the playground and connect to it with `astrona ssh section-070-module-02-playground`. Run every command in the parts in that shell.

## The parts of this module

1. [From Device to Process: iotop & pidstat](./course-01-iotop-and-pidstat.md): per-process I/O rates, why `iotop` depends on delay accounting, and `pidstat -d` as the fallback.
2. [Where Per-Process I/O Numbers Come From](./course-02-per-process-io-counters.md): the counters in `/proc/<PID>/io` and what each field counts.
3. [lsof: Which File, Which Process](./course-03-lsof-files-and-processes.md): from a PID to its files, from a file to its users, and deleted files that still use space. A graded mission ends this part.
4. [Closing the Loop](./course-04-closing-the-loop.md): chain device, mount, process and file into one diagnosis.
5. [Wrap-Up: Mission Debrief](./course-05-wrap-up.md): what you learned, your mission, questions to check yourself, and cleanup.
