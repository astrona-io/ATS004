# Process-Level Auditing: Identifying the Culprit

If `iostat` tells you that the kitchen dishwasher is overwhelmed, your next job is to figure out who is dropping off all the dirty plates. Knowing that `/dev/sda` is at 100% utilization doesn't help you fix the server if you don't know *which* application is writing to it.

You need to trace the active waiters back to their tables.

## Tracking Real-Time Process Throughput (iotop)

The standard `top` command shows you CPU and memory usage, but it hides I/O wait. To see exactly which processes are consuming disk bandwidth, you use `iotop`.

Because servers run hundreds of idle background tasks, running a raw `iotop` command floods the screen with zeroes. You must filter the output to show only the processes actively performing I/O right now.

```bash
iotop -o
```

The `-o` (only) flag clears the noise. The resulting screen updates in real-time, displaying the PID, the user running it, and the exact bytes-per-second they are reading or writing to the disk. If a rogue Python script is stuck in an infinite logging loop, it will immediately jump to the top of the `iotop` list, clearly displaying its massive write throughput.

## Tracing Open Files (lsof)

Once `iotop` gives you the PID of the offending process, you need to know exactly what file it is destroying. If the PID belongs to a generic database service, you need to know which specific database table or log file is generating the load.

You query the active file handles of that specific process using `lsof` (List Open Files).

```bash
lsof -p 4050
```

The `-p` flag targets a specific PID. The output will list every shared library, network socket, and physical file the process currently has open. You scan the "NAME" column for files living on the saturated mount point.

If `iostat` shows `/dev/sdb` is saturated, and `df -h` shows `/dev/sdb` is mounted at `/var/log`, and `lsof` shows PID 4050 is rapidly writing to `/var/log/app/debug.log`, you have found your root cause. You can now confidently kill the process, rotate the log, or fix the application configuration.

## Self-Check and Verification

To prove you can trace an I/O bottleneck to its source:

1. Open two terminal sessions.
2. In the first terminal, generate a slow, continuous background write load using `dd if=/dev/zero of=/var/tmp/leak.log bs=1M count=1000 &`. Note the PID returned by the shell.
3. In the second terminal, run `iotop -o`.
4. Identify the `dd` process at the top of the list and verify its disk write rate. Note its PID.
5. Exit `iotop` and run `lsof -p <PID>` using the number you just identified.
6. Scan the output to verify the process is holding open a file descriptor pointing exactly to `/var/tmp/leak.log`.
