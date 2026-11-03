# I/O Wait, IOPS & Throughput

Before you touch `iostat`, get two ideas straight. The first is what I/O wait really is for a process. The second is the difference between a load limited by how much data moves and a load limited by how many requests are made. Mix them up and a healthy disk looks broken, or a saturated one looks fine.

## I/O wait

Picture a ship with a fast crew and one slow cargo lift. The crew can only work as fast as crates come up. When they stand idle waiting for the lift, that is I/O wait. The lift is the bottleneck, not the crew.

> As an analogy: the crew is the CPU and the cargo lift is the disk. The analogy breaks down because a real ship has many crew members (cores) and a deep line of waiting requests, so the stall shows up as delay statistics, not as one visibly idle worker.

### What the kernel does

A process that asks for data that must come from the disk (not from the page cache in memory) is put to sleep in a special state: **uninterruptible sleep**. `ps` and `top` show it as state `D`. The process stays there until the disk finishes the request.

A process in `D` state cannot be stopped even with `SIGKILL`. The kernel delivers no signal until the I/O completes, because a process deep inside a block-layer wait is not at a point where it can be resumed to handle a signal. That is why a process stuck on a dead disk can be unkillable until the device error times out.

### Where you see it

In `top`, the `wa` value on the CPU line is the share of time the cores had work waiting on I/O. A high `wa` with little user or system time is the mark of a storage bottleneck.

<!-- astrona:playground:renew -->

### See it in your playground

Take one snapshot of `top` and read the CPU line, then list any process in state `D`.

```sh
top -bn1 | head -n 4
ps -eo state,pid,comm | awk '$1=="D"'
```

The first command prints the top of `top` in batch mode, and the `%Cpu(s)` line has a `wa` value. On an idle ship it is close to 0. The second command prints one line for each process in `D` state. On an idle ship it usually prints nothing, because no process is waiting on the disk.

## IOPS versus throughput

Two different things stress a disk, and they fail in different ways. This section names both and shows why one can hide behind the other.

> As an analogy: moving ten tons of sand in one dump-truck trip is **throughput**, the bytes moved per second in big sequential transfers, such as a backup reading a large file. Moving it by the teaspoon is **IOPS**, the number of operations per second, as when a database makes thousands of small transactions. The analogy breaks down on flash and virtual disks, where there is no physical trip. The cost of many small requests is still real, only smaller than on a spinning disk.

### Why the two limits differ

Every I/O request has a roughly fixed setup cost. On a spinning disk that cost is mostly seek and rotation. On flash it is command and queue overhead. A large sequential transfer spreads that cost over many megabytes, so the byte rate shows the limit. A stream of small scattered requests pays the cost again and again for only 4 KiB each, so the count of operations hits its ceiling first.

`iostat` reports both, in separate columns. `rkB/s` and `wkB/s` are throughput. `r/s` and `w/s` are IOPS. A device can be at its limit on one while the other looks ordinary. A load of 10,000 tiny writes per second can saturate a disk while `wkB/s` is only 40,000, and the byte rate alone would not tell you the disk is in trouble.

> *A device has one ceiling for operations per second and another for bytes per second, and a load can hit either one first.*

## Common pitfalls

> [!WARNING]
> - **Treating high `wa` as a CPU problem.** High I/O wait with idle user CPU is a storage problem. Adding CPU will not help.
> - **Trying to kill a process in `D` state.** `kill -9` has no effect until the I/O finishes. Look at the device, not at the signal.
> - **Judging a disk by bytes per second only.** A disk can be saturated by small requests while the byte rate looks low. Always read `w/s` next to `wkB/s`.
> - **Counting cached reads.** A read answered from the page cache never reaches the disk, so it causes no I/O wait.
