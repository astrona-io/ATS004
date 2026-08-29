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

## Learning objectives

After this module you can:

- Explain what I/O wait is and why a slow disk can leave the CPU idle.
- Distinguish an IOPS-bound workload from a throughput-bound one.
- Run `iostat` in the form that is useful for live debugging.
- Read `%util`, `aqu-sz`, and `r_await`/`w_await` to judge whether a device is saturated.
- Tell a throughput-bound load from an IOPS-bound one by comparing `wkB/s` with `w/s`.

## Before you start

You should know how to open a second shell to the same machine and how to read tabular command output.

The linked playground gives you an Ubuntu server VM with `sysstat` (`iostat`, `pidstat`) and `fio` installed, and a spare 4 GB disk carrying an ext4 filesystem mounted at `/mnt/perf` — stress that, not the root disk. Two helpers are on `PATH`: `start-io-load seq` (sequential writes), `start-io-load rand` (small random writes), and `stop-io-load`. Run the command blocks below in that VM after `astrona ssh section-070-module-01-playground`.

## I/O wait

> As an analogy: a kitchen has a fast chef (the CPU) and one slow dishwasher (the disk). The chef can only plate as fast as clean plates come back. When the chef is standing idle waiting for the dishwasher, that is I/O wait — the bottleneck is the dishwasher, not the chef. The analogy breaks down because a real system has many "chefs" (cores) and deep request queues, so the stall shows up as latency statistics rather than a visibly idle worker.

In tools like `top`, I/O wait appears as the `wa` percentage in the CPU line. A high `wa` with low user/system CPU is the signature of a storage bottleneck: there is work to do, but it is all blocked on the disk.

## IOPS versus throughput

Two different things stress a disk, and they fail differently.

> As an analogy: moving ten tons of sand in one dump-truck trip is **throughput** — bytes per second, big sequential transfers, like a backup reading a large file. Moving the same ten tons by the teaspoon is **IOPS** — operations per second, many tiny scattered requests, like a database doing thousands of small transactions. The analogy breaks down on solid-state and virtualised disks, where there is no physical "trip" to make: the teaspoon penalty is real but far smaller than on a spinning disk with a moving head.

`iostat` reports both: `rkB/s` / `wkB/s` are throughput, `r/s` / `w/s` are IOPS. A device can be maxed out on one while the other looks low.

## Reading `iostat`

Run without options, `iostat` prints one average since boot — no use for a live problem. For debugging you want a fresh sample every second, the extended columns, and idle devices hidden:

```sh
iostat -xz 1
```

- `-x` — extended statistics (the latency and queue columns).
- `-z` — omit devices with no activity this interval.
- `1` — repeat every 1 second. Add a count (`iostat -xz 1 5`) to stop after five samples.

The columns that diagnose a bottleneck:

| Column | Meaning |
| --- | --- |
| `%util` | Percentage of the interval the device had at least one request in flight. Near 100 means "always busy" — a strong signal on a single spinning disk, weaker on SSDs and RAID (see pitfalls). |
| `aqu-sz` | Average number of requests queued plus in service. Climbing = requests arriving faster than the device clears them. (Older `sysstat` called this `avgqu-sz`.) |
| `r_await` / `w_await` | Average time in milliseconds for a read / write request to complete, queue time included. This is the latency applications actually feel. (Older `sysstat` reported a single combined `await`.) |
| `r/s` / `w/s` | Read / write requests completed per second — IOPS. |
| `rkB/s` / `wkB/s` | Kilobytes read / written per second — throughput. |

> [!TIP]
> **Try it — the idle baseline**
>
> ```sh
> iostat -xz 1 3
> ```
>
> Expect something like:
>
> ```text
> Device   r/s   w/s  rkB/s  wkB/s  r_await  w_await  aqu-sz  %util
> vda     0.00  1.20   0.00   6.40     0.00     0.30    0.00   0.13
> ```
>
> On an idle VM only the root device (`vda`) shows the odd housekeeping write; `%util` is a fraction of a percent, `aqu-sz` ≈ 0, `w_await` is sub-millisecond. `/mnt/perf`'s device does not appear at all — `-z` hid it because nothing is touching it. This is what "healthy" looks like.

## Watching a device saturate

Now generate load on `/mnt/perf` from a second shell and watch the same columns move.

> [!TIP]
> **Try it — drive one device to 100%**
>
> In a second shell:
>
> ```sh
> start-io-load seq
> ```
>
> Back in the first shell:
>
> ```sh
> iostat -xz 1
> ```
>
> Expect something like:
>
> ```text
> Device   r/s    w/s   rkB/s    wkB/s  r_await  w_await  aqu-sz  %util
> vdb     0.00  480.0    0.00  491000     0.00     4.10    2.00   99.8
> ```
>
> The spare disk (`vdb` here) is now in the list: `%util` is pinned near 100, `aqu-sz` sits around 1–3 (requests waiting), and `w_await` has risen from sub-millisecond to several milliseconds. `wkB/s` in the hundreds of thousands with a moderate `w/s` says this is a big-transfer, throughput-bound load. Run `stop-io-load` and the device drops back off the list within a second or two.

## Throughput-bound versus IOPS-bound

The two load modes stress different limits. `start-io-load seq` writes in 1 MiB chunks — few operations, many bytes. `start-io-load rand` writes 4 KiB blocks to scattered offsets — many operations, few bytes each. Comparing `w/s` against `wkB/s` tells them apart.

> [!TIP]
> **Try it — compare the two shapes of load**
>
> ```sh
> stop-io-load
> start-io-load rand
> iostat -xz 1
> ```
>
> Expect something like:
>
> ```text
> Device   r/s     w/s   rkB/s   wkB/s  r_await  w_await  aqu-sz  %util
> vdb     0.00  9800.0    0.00   39200     0.30     0.75    7.20   99.5
> ```
>
> Against the sequential run, `w/s` jumped from a few hundred to several thousand while `wkB/s` fell sharply — the device is busy doing *many small* writes, not moving bulk data. `aqu-sz` is higher because small requests pile up. On a physical spinning disk `w_await` would balloon here as the head seeks; on this virtio disk the effect is milder but the IOPS/throughput contrast is still clear. `stop-io-load` when done.

> [!WARNING]
> **Common pitfalls**
>
> - **Trusting `%util` on SSDs or RAID.** These devices service many requests in parallel, so `%util` can read 100 while the device still has headroom. Use `aqu-sz` and `w_await` alongside it, not `%util` alone.
> - **Reading `iostat` with no interval.** A bare `iostat` shows an average since boot that hides any current spike. Always give an interval (`iostat -xz 1`) for live work.
> - **Assuming one `await` number.** Current `sysstat` splits it into `r_await` and `w_await`, and renamed `avgqu-sz` to `aqu-sz`. Older docs and older systems differ.
> - **Fixed latency thresholds.** "20–30 ms is bad" is a rough guide for spinning disks. An all-flash array in trouble might be at 2 ms; a healthy archive disk might sit at 15 ms. Compare against that device's own baseline.
> - **Blaming the CPU.** High load average with high I/O wait and idle user CPU is a storage problem. Check `iostat` before adding CPU.
