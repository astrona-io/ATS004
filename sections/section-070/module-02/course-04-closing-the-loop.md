# Closing the Loop

You now have four tools. Each one answers a narrower question. This part chains them into one diagnosis that you can state with confidence: this device, this mount, this process, this file.

## The chain

Think of a flight investigator. First find which hold is under strain, then which hatch it is docked to, then which crew member is busy there, then which crate they are handling. Skip a step and you are guessing.

### The sources behind each step

```mermaid
flowchart LR
    A["iostat -xz 1"] -->|"device"| B["findmnt"]
    B -->|"mount point"| C["iotop or pidstat"]
    C -->|"PID"| D["lsof"]
    D -->|"file"| E["Diagnosis"]
```

The diagram shows the order of the tools and what each one hands to the next.

Each arrow uses a different source. `iostat` reads the block-layer device counters. `findmnt` reads the mount table. `iotop` and `pidstat` read per-process I/O accounting. `lsof` reads the open-file table. No single command can say which file on which device. The chain is the technique.

<!-- astrona:playground:renew -->

### See it in your playground

Run the full trace while the writer is busy. Start it first if you stopped it.

```sh
iostat -xz 1 2
findmnt --noheadings --output SOURCE,TARGET /mnt/perf
pidstat -d 1 1
sudo lsof /mnt/perf/leak.log
stop-io-load
```

Expect something like this (the arrows are added here to explain each line and are not part of the output):

```text
Device   w/s    wkB/s  w_await  aqu-sz  %util
vdb    210.0   215000     4.20    1.90   99.5      <- device vdb is saturated

/dev/vdb  /mnt/perf                                <- vdb is mounted at /mnt/perf

   UID   PID   kB_wr/s  Command
  1000  2451  215000.00  fio                       <- PID 2451 is the writer

fio 2451 ubuntu  5u  REG  254,16  ...  /mnt/perf/leak.log   <- writing this file
```

The four commands form one sentence. Device `vdb` is at 100 percent. `vdb` is mounted at `/mnt/perf`. PID 2451 writes about 210 MB per second. The file is `/mnt/perf/leak.log`. That is a complete diagnosis, and `stop-io-load` clears it.

## Your mission: Storage Performance: iotop and lsof Active Profiling Lab

You can now go from a busy device to the process and the file behind it. The mission asks you to find the PID of a rogue writer and the path of the file it writes, and record both.

The mission runs on its own training ship. A playground cannot be paused, so remove it first to free memory. It always starts clean again:

```sh
astrona destroy section-070-module-02-playground
```

Then start the mission and connect to it:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-070/module-02/labs/lab-01
astrona ssh ats-004-lab-072
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-070/module-02/labs/lab-01
```

When the mission is done, remove it and start a fresh playground:

```sh
astrona destroy ats-004-lab-072
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-070/module-02/playground
```

## Common pitfalls

> [!WARNING]
> - **Skipping a link in the chain.** A busy process may write to another disk than the one `iostat` flagged. Confirm the file sits on the flagged mount.
> - **`iotop` shows all zeros.** Delay accounting is off or you are not root. Use `sudo`, enable `kernel.task_delayacct`, or use `pidstat -d`.
> - **Confusing TID with PID.** `iotop` shows threads by default. Add `-P` to group by process.
> - **Acting before tracing.** Confirm device, mount and file first, then decide whether to stop, rotate or fix.
