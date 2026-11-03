# Where iostat Gets Its Numbers

`iostat` does not measure the disk itself. It reads counters that the kernel keeps for each block device, reads them again a moment later, and does arithmetic. Once you know the counters, every column has a clear meaning, and you can tell when a column cannot be trusted.

## The counters in `/proc/diskstats`

The kernel's block layer counts every request it handles, per device. Think of the cargo officer's tally sheet: crates lifted, minutes the lift ran, and so on. The totals only go up. This section shows the sheet.

### One line per device

Each line of `/proc/diskstats` starts with the device's major number, minor number and name. After the name come the counters, in this order:

| Position after the name | Counter |
| --- | --- |
| 1 | Reads completed |
| 2 | Reads merged |
| 3 | Sectors read (a sector here is always 512 bytes) |
| 4 | Milliseconds spent reading |
| 5 | Writes completed |
| 6 | Writes merged |
| 7 | Sectors written |
| 8 | Milliseconds spent writing |
| 9 | Requests in progress right now |
| 10 | Milliseconds the device was doing I/O |
| 11 | Weighted milliseconds spent doing I/O |

Newer kernels add more counters after these for discards and flushes. The first eleven are the ones that matter here. Only counter 9 can go down. All the others are totals since boot.

The same counters for one device are in `/sys/block/<dev>/stat`, without the first three fields.

<!-- astrona:playground:renew -->

### See it in your playground

Read the line for the root disk twice, a few seconds apart, and compare.

```sh
grep -w vda /proc/diskstats
sleep 5
grep -w vda /proc/diskstats
cat /sys/block/vda/stat
```

Each command prints one line of numbers. In the second reading the totals are the same or higher than in the first, never lower. The last command prints the same counters without the leading major, minor and name.

## From counters to columns

A single reading is only a total since boot. `iostat` reads twice, subtracts, and divides by the seconds between the two reads. This section shows how each column comes out of that arithmetic.

### The formulas

Let each "delta" be the second reading minus the first.

- `r/s` and `w/s` are the delta of reads or writes completed, divided by the seconds.
- `rkB/s` and `wkB/s` are the delta of sectors times 512, divided by 1024, divided by the seconds.
- `r_await` is the delta of milliseconds reading divided by the delta of reads completed. `w_await` works the same for writes. This is the average time per request, queue wait included.
- `%util` is the delta of milliseconds doing I/O, divided by the milliseconds that passed, times 100.
- `aqu-sz` is the delta of weighted milliseconds, divided by the milliseconds that passed. It is the average number of requests in the queue and in service.

### A worked example

These are example numbers to show the arithmetic. They are not output from your ship. Over a 1-second gap, 100 writes completed, the device spent 400 milliseconds writing, and it was doing I/O for 500 milliseconds. Then `w/s` is 100, `w_await` is 400 divided by 100, which is 4 milliseconds, and `%util` is 500 divided by 1000 times 100, which is 50 percent.

### Why the first report is different

`iostat` with no interval has only one reading, so it divides by the time since boot. That is an average over days. A live problem is hidden in it. With an interval, the first report still shows the average since boot, and every report after it shows the last interval.

### See it in your playground

Ask for two reports one second apart, and note that the first one covers the time since boot.

```sh
iostat -x 1 2
```

The output has two blocks. The first block shows averages since boot. The second block is the last second. On an idle ship the second block has `%util` close to 0.

## Common pitfalls

> [!WARNING]
> - **Reading the first `iostat` report as "now".** It is the average since boot. Use the second and later reports.
> - **Reading `/proc/diskstats` as a rate.** The values are totals. A rate needs two reads.
> - **Forgetting that a sector is 512 bytes in these counters.** This holds even on disks with 4096-byte sectors, so multiply by 512, not by the disk's own sector size.
> - **Treating `%util` as "how full the lift is".** It only says the device had at least one request in flight. It says nothing about how many requests it could handle at once.
