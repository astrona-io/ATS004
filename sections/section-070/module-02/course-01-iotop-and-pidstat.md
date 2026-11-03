# From Device to Process: iotop & pidstat

`iostat` tells you that a device is saturated. It does not tell you which process is responsible. This part covers the two tools that turn "the disk is busy" into "this process is hammering it": `iotop`, which needs a kernel feature switched on, and `pidstat -d`, which does not.

## From device to process

After `iostat` points at a device, the plan has three steps. Find the process with the most I/O. Find the file it is writing. Check that the file lives on the flagged device. Each step narrows the problem until you can act: rotate a log, fix a setting or stop a runaway job.

## `iotop`: per-process I/O rates

`iotop` is `top` for disk I/O. It does not read the same kind of data that `top` reads for CPU. CPU time is always counted by the scheduler. Disk I/O time per process is only counted when the kernel is told to count it.

### Why `iotop` can show zeros

That counting is **task delay accounting**. It records, for each task, the time spent blocked on I/O, swapping and a few other things, and shows it through a netlink interface that `iotop` reads. From kernel 5.14 on it is off by default, to save cost. With it off, every row in `iotop` reads `0.00 B/s`, whatever the processes really do, because nothing supplies the numbers.

Turn it on with `sysctl -w kernel.task_delayacct=1`. The playground has already done this. Like every runtime sysctl write, it is lost at reboot unless a file in `/etc/sysctl.d/` also holds the line `kernel.task_delayacct = 1`.

### The useful options

Plain `iotop` lists every process, most at `0.00 B/s`, which hides the one that matters. `iotop -o` shows only processes doing I/O right now. `-b` runs in batch mode, with plain lines instead of a full-screen display. `-n <count>` stops after that many samples. `iotop` needs root, because reading another user's delay-accounting data is a privileged action.

<!-- astrona:playground:renew -->

### See it in your playground

Start the writer and find it.

```sh
start-io-load
sudo iotop -o -b -n 3 -d 1
```

Expect something like this:

```text
write load started, PID 2451  (file: /mnt/perf/leak.log)

Total DISK READ:   0.00 B/s | Total DISK WRITE: 210.00 M/s
   TID  PRIO  USER   DISK READ  DISK WRITE  COMMAND
  2451  be/4  ubuntu   0.00 B/s  210.00 M/s  fio --name=leak ...
```

Only the `fio` writer shows up, because `-o` filters to processes doing I/O. You see its write rate and its command line. The PID is your lead. If every row read `0.00 B/s`, delay accounting would be off.

## `pidstat -d`: the alternative with no tunable

`pidstat -d <interval>`, from `sysstat`, reports per-process read and write rates from a different source. It reads the always-on I/O counters in `/proc/<PID>/io`, which have no switch. So it works without root for your own processes, and without any kernel setting. That is why it is the dependable fallback.

### See it in your playground

Read the same picture from `pidstat`.

```sh
pidstat -d 1 3
```

Expect something like this:

```text
#      Time   UID       PID   kB_rd/s   kB_wr/s kB_ccwr/s  Command
   12:00:01  1000      2451      0.00 215000.00      0.00  fio
```

`kB_wr/s` for PID 2451 matches what `iotop` showed. Reach for `pidstat -d` first when `iotop` does not cooperate.

> *`iotop` and `pidstat -d` measure the same thing from two kernel sources. One is behind a switch and the other is always on, which is why the second is the fallback for the first.*

## Common pitfalls

> [!WARNING]
> - **`iotop` shows all zeros.** Task delay accounting is off (the default from kernel 5.14) or you are not root. Run `sudo sysctl -w kernel.task_delayacct=1`, use `sudo`, or use `pidstat -d`.
> - **Confusing TID with PID.** `iotop` shows thread IDs by default, so a multithreaded process appears as several rows. Add `-P` to group by process, and check the number with `ps`.
> - **Keeping the setting only at runtime.** `sysctl -w` is lost at reboot. Write it to `/etc/sysctl.d/` to keep it.
> - **Running `iotop` without `-o`.** The one busy process hides in a list of idle ones.
