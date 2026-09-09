# Device-Level Diagnostics: Queues & Latency

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-070/module-01/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-070/module-01/playground
> astrona destroy section-070-module-01-playground
> ```

When a server feels slow, the CPU is often not the problem — it is idle, blocked, waiting for a disk to return data. That blocked-waiting state is **I/O wait**. This module is about measuring it at the device level: telling a saturated disk from a healthy one, and reading the queue and latency numbers that say how bad it is.

The tool is `iostat`. Most of the work is knowing which of its many columns matter and what their values mean.

## How this module is organised

1. **[Part 1 — I/O Wait, IOPS & Throughput](./course-01-io-wait-iops-throughput.md)** — what I/O wait actually is at the process level (the `D` state and why it can't be signalled), and the physical reason IOPS-bound and throughput-bound loads hit different ceilings.
2. **[Part 2 — Reading iostat & Watching Saturation](./course-02-iostat-and-saturation.md)** — the `iostat -xz 1` columns, what `await` actually measures and why it can disagree with `%util`, and watching a real device cross from idle into saturated under both load shapes.

## Learning objectives

After this module you can:

- Explain what I/O wait is, the process state it corresponds to, and why a slow disk can leave the CPU idle.
- Distinguish an IOPS-bound workload from a throughput-bound one, and explain the per-operation-overhead reason they hit different limits.
- Run `iostat` in the form that is useful for live debugging.
- Explain what `r_await`/`w_await` actually measure (queue time included) and why they can disagree with `%util` on SSDs and RAID.
- Read `%util`, `aqu-sz`, and `r_await`/`w_await` to judge whether a device is saturated.
- Tell a throughput-bound load from an IOPS-bound one by comparing `wkB/s` with `w/s`.

## Before you start

You should know how to open a second shell to the same machine and how to read tabular command output.

The linked playground gives you an Ubuntu server VM with `sysstat` (`iostat`, `pidstat`) and `fio` installed, and a spare 4 GB disk carrying an ext4 filesystem mounted at `/mnt/perf` — stress that, not the root disk. Two helpers are on `PATH`: `start-io-load seq` (sequential writes), `start-io-load rand` (small random writes), and `stop-io-load`. Run the command blocks in both parts in that VM after `astrona ssh section-070-module-01-playground`.
