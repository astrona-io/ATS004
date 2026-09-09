# Part 1 — I/O Wait, IOPS & Throughput

> Prerequisite: [Module landing page](./course.md). Next: [Part 2 — Reading iostat & Watching Saturation](./course-02-iostat-and-saturation.md).

Before touching `iostat`, get the two ideas straight that every column in it exists to measure: what I/O wait actually is at the process level, and the difference between a workload limited by *how much data* moves versus one limited by *how many operations* happen. Get these backwards and a healthy device looks broken, or a genuinely saturated one looks fine.

## I/O wait

> As an analogy: a kitchen has a fast chef (the CPU) and one slow dishwasher (the disk). The chef can only plate as fast as clean plates come back. When the chef is standing idle waiting for the dishwasher, that is I/O wait — the bottleneck is the dishwasher, not the chef. The analogy breaks down because a real system has many "chefs" (cores) and deep request queues, so the stall shows up as latency statistics rather than a visibly idle worker.

Underneath, I/O wait is a specific kernel state: a process that has issued a block I/O request (a read that must actually hit the disk, not one satisfied from the page cache) is put into **uninterruptible sleep** — `ps`/`top` report this as state `D` — until the I/O completes. A process in `D` state cannot even be killed with `SIGKILL`; the kernel will not deliver *any* signal to it until the I/O it is waiting on finishes, because signal delivery happens at a point in the kernel where the process is resumable, and a process blocked deep inside a block-layer wait is not. This is why a process stuck on a truly dead disk can be unkillable until the underlying device error times out.

In tools like `top`, the aggregate of all cores' time spent with at least one such process waiting appears as the `wa` percentage in the CPU line. A high `wa` with low user/system CPU is the signature of a storage bottleneck: there is work queued, but every core with something to do is one whose runnable work is blocked in `D`, not one that has nothing to do.

## IOPS versus throughput

Two different things stress a disk, and they fail differently.

> As an analogy: moving ten tons of sand in one dump-truck trip is **throughput** — bytes per second, big sequential transfers, like a backup reading a large file. Moving the same ten tons by the teaspoon is **IOPS** — operations per second, many tiny scattered requests, like a database doing thousands of small transactions. The analogy breaks down on solid-state and virtualised disks, where there is no physical "trip" to make: the teaspoon penalty is real but far smaller than on a spinning disk with a moving head.

The physical reason the two loads behave differently is **per-operation overhead**. Every I/O request costs a roughly fixed amount of time to set up and complete — on a spinning disk, dominated by seek and rotational latency; on flash, dominated by command/queue overhead — on top of the time actually proportional to the data moved. A large sequential transfer amortises that fixed cost over many megabytes, so throughput dominates the picture. A stream of small, scattered requests pays that fixed cost over and over for only 4 KiB at a time, so the *count* of operations — IOPS — becomes the limit long before the byte rate looks impressive.

`iostat` reports both, as separate column pairs: `rkB/s` / `wkB/s` are throughput, `r/s` / `w/s` are IOPS. A device can be maxed out on one while the other looks unremarkable — a workload doing 10,000 tiny writes/second can saturate a disk while `wkB/s` reads a modest 40,000, and nothing about that byte-rate number alone would tell you the device is in trouble.

> *A device is not "fast" or "slow" in the abstract — it has a ceiling on operations per second and a separate ceiling on bytes per second, and a workload can hit either one first.*

## Reference

- `man 1 top` — the `wa` field in the CPU summary line, and process state codes (`D` among them) in the process list.
- `man iostat` — full column reference; the next part uses it directly.
