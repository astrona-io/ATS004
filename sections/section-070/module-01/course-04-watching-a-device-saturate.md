# Watching a Device Saturate

Now you generate load on the spare disk and watch the same columns move. You run two load shapes, one that moves many bytes in few requests and one that makes many small requests, and read the difference.

## A throughput-bound load

The helper `start-io-load seq` writes to `/mnt/perf` in 1 MiB chunks. That makes few operations and moves many bytes.

<!-- astrona:playground:renew -->

### See it in your playground

You need two shells on the ship. In the second shell, start the load:

```sh
start-io-load seq
```

In the first shell, watch the device:

```sh
iostat -xz 1
```

Expect something like this (shortened to the columns used here):

```text
Device   r/s    w/s   rkB/s    wkB/s  r_await  w_await  aqu-sz  %util
vdb     0.00  480.0    0.00  491000     0.00     4.10    2.00   99.8
```

The spare disk, `vdb` here, is now in the list. `%util` is near 100, `aqu-sz` is around 1 to 3 and `w_await` has risen from under a millisecond to several. A `wkB/s` in the hundreds of thousands with a moderate `w/s` marks a big-transfer, throughput-bound load. Run `stop-io-load` and the device leaves the list within a second or two.

## An IOPS-bound load

The helper `start-io-load rand` writes 4 KiB blocks to scattered places on the disk. That makes many operations that each move few bytes. Comparing `w/s` with `wkB/s` tells the two loads apart.

### See it in your playground

Stop the first load, start the second and watch again.

```sh
stop-io-load
start-io-load rand
iostat -xz 1
```

Expect something like this (shortened):

```text
Device   r/s     w/s   rkB/s   wkB/s  r_await  w_await  aqu-sz  %util
vdb     0.00  9800.0    0.00   39200     0.30     0.75    7.20   99.5
```

Against the first run, `w/s` jumped from a few hundred to thousands while `wkB/s` fell sharply. The disk is busy with many small writes, not with bulk data. `aqu-sz` is higher because small requests pile up. On a spinning disk `w_await` would balloon as the head seeks. This virtual disk shows a milder effect, but the contrast between IOPS and throughput is still clear. Run `stop-io-load` when you finish.

## Your mission: Storage Performance Monitoring: iostat Wait Latency Lab

You can now read `iostat`, and tell a saturated device from a healthy one. The mission asks you to find which of several disks is the saturated one and record its name.

The mission runs on its own training ship. A playground cannot be paused, so remove it first to free memory. It always starts clean again:

```sh
astrona destroy section-070-module-01-playground
```

Then start the mission and connect to it:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-070/module-01/labs/lab-01
astrona ssh ats-004-lab-071
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-070/module-01/labs/lab-01
```

When the mission is done, remove it and start a fresh playground:

```sh
astrona destroy ats-004-lab-071
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-070/module-01/playground
```

## Common pitfalls

> [!WARNING]
> - **Stopping the load too early.** The device needs a few seconds to show a steady picture. Read the second and later reports, not the first.
> - **Starting both loads at once.** The two loads mix and you cannot tell the shapes apart. Run `stop-io-load` before you start the other.
> - **Expecting a spinning-disk result on a virtual disk.** The seek cost is small here, so the gap between the two loads is smaller than on real spinning disks.
> - **Naming the wrong device.** Map the busy device back to its mount with `findmnt` before you act on it.
