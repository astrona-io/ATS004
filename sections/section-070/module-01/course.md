# Device-Level Diagnostics: Queues & Latency

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-070/module-01/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-070/module-01/playground
> astrona destroy section-070-module-01-playground
> ```

When a ship feels slow, the crew is often not the problem. They stand idle, waiting for the cargo lift to bring the next crate. That waiting state is **I/O wait**. This module is about measuring it at the level of one cargo hold: telling a saturated hold from a healthy one, and reading the queue and delay numbers that say how bad it is.

The tool is `iostat`. You also learn where it gets its numbers, so each column makes sense and you know when it can mislead you.

## Learning objectives

After this module you can:

- Explain what I/O wait is, the process state it corresponds to, and why a slow disk can leave the CPU idle.
- Distinguish an IOPS-bound workload from a throughput-bound one, and explain the per-operation-overhead reason they hit different limits.
- Name the fields in `/proc/diskstats` and explain how `iostat` turns two readings of it into rates, `await`, `aqu-sz` and `%util`.
- Run `iostat` in the form that is useful for live debugging.
- Explain what `r_await` and `w_await` measure (queue time included) and why they can disagree with `%util` on SSDs and RAID.
- Read `%util`, `aqu-sz`, and `r_await`/`w_await` to judge whether a device is saturated.
- Tell a throughput-bound load from an IOPS-bound one by comparing `wkB/s` with `w/s`.

## Before you start

Every mission starts with a pre-flight check. Make sure you know the basics below, and know what waits for you in your training ship.

### What you should already know

- How to open a second shell to the same machine.
- How to read a table of command output.

### What is in your playground

Your playground is one training spaceship: an Ubuntu 24.04 virtual machine with passwordless `sudo`.

- `sysstat` (which gives you `iostat` and `pidstat`) and `fio` are installed.
- A spare 4 GB disk carries an ext4 filesystem mounted at `/mnt/perf`. Stress that disk, not the root disk. It is usually `/dev/vdb`, so confirm the name with `lsblk`.
- Two helpers are on your `PATH`. `start-io-load seq` starts sequential writes, `start-io-load rand` starts small random writes, and `stop-io-load` ends any load.

Start the playground and connect to it with `astrona ssh section-070-module-01-playground`. Run every command in the parts in that shell.

## The parts of this module

1. [I/O Wait, IOPS & Throughput](./course-01-io-wait-iops-throughput.md): what I/O wait is at the process level, and why IOPS-bound and throughput-bound loads hit different ceilings.
2. [Where iostat Gets Its Numbers](./course-02-where-iostat-gets-its-numbers.md): the counters in `/proc/diskstats` and how two readings become rates, delays and `%util`.
3. [Reading iostat Columns](./course-03-reading-iostat-columns.md): the `iostat -xz 1` form, each column, and why `%util` can mislead.
4. [Watching a Device Saturate](./course-04-watching-a-device-saturate.md): drive a disk to its limit with both load shapes and read the verdict.
5. [Wrap-Up: Mission Debrief](./course-05-wrap-up.md): what you learned, your mission, questions to check yourself, and cleanup.
