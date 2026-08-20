# Solution

## Step 1: Get a fast system-wide signal with vmstat

Check `man 1 vmstat` — the field descriptions define `bi` (blocks received from a block device, KB/s) and `wa` (percentage of CPU time spent idle while waiting for I/O to complete); the page also notes the first reported line is a since-boot average, not a live sample.

```bash
vmstat 1 5
```

Ignore the first line of output (boot-average, as noted above) and look at lines 2-5. A sustained high `wa` value (for example, consistently above 20-30% on a system that should otherwise be mostly idle or CPU-bound) is your justification to dig further with `iostat`/`iotop`. Elevated `bi`/`bo` alongside high `wa` reinforces that real block-device traffic is happening, not just CPU scheduling delay.

## Step 2: Break utilization and latency down per device with iostat

Check `man 1 iostat` — the `-x` section documents `%util`, `await`, `r/s`, and `w/s`; read the note (in most versions of the page) cautioning that `%util` approaching 100% does not, by itself, guarantee the device is a bottleneck on devices capable of servicing multiple requests concurrently.

```bash
iostat -xz 1 5
```

`-x` requests extended statistics (utilization, latency, queue size), `-z` suppresses devices with zero activity so the output stays readable, and `1 5` repeats every second for five samples — again, disregard the first sample as a since-boot average.

Example (abridged) output for one interval:

```
Device   r/s     w/s   rkB/s   wkB/s  await  %util
vda      2.00    1.00    64.0    32.0   1.20    3.00
vdb      12.00  145.00   768.0  9280.0  48.70   97.50
```

Here `/dev/vdb` stands out clearly: `%util` near saturation (97.5%) *and* a high `await` (48.7ms, well above what a healthy disk should show for typical workloads) — this combination is what justifies calling `/dev/vdb` the bottleneck, not `%util` alone. (This walkthrough's example happens to land on `vdb` — your own run may flag a different letter. Don't assume which device it'll be; read it off your own `iostat` output each time, since extra disks aren't guaranteed to attach in any particular order relative to the VM's own root disk.)

## Step 3: Determine read-bound vs write-bound from the same output

Looking at the same `/dev/vdb` line: `w/s` (145.00) and `wkB/s` (9280.0) dwarf `r/s` (12.00) and `rkB/s` (768.0) — both the request rate and the throughput are overwhelmingly on the write side. This device's load is clearly **write-bound**. If your `iostat` version splits `await` into `r_await`/`w_await`, compare those too — a write-bound workload typically (though not always) shows the write-side latency dominating the blended `await` figure as well.

## Step 4: Identify the process responsible with iotop

Check `man 8 iotop` — the `-o`/`--only` option is documented as restricting output to processes actually performing I/O during the sampling window, which cuts through the noise of hundreds of idle processes.

```bash
sudo iotop -o
```

This launches an interactive, continuously-refreshing view sorted by I/O activity, showing PID, user, and current read/write rates per process. Whichever process shows a large, sustained `WRITE` rate matching the scale of `/dev/vdb`'s throughput from Step 2 is your culprit — in this lab that's the `data-ingest-job` process. For a one-shot, non-interactive capture suitable for scripting or logging:

```bash
sudo iotop -o -b -n 3
```

`-b` (batch mode) and `-n 3` (three iterations) make `iotop` print plain output instead of a live curses UI, useful when you want to grep or redirect the result. Note the PID it reports.

## Step 5: Map the busy device back to its mountpoint

```bash
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT
```

or, targeted directly at the device in question (substitute whatever device `iostat` actually flagged for you):

```bash
lsblk -o NAME,MOUNTPOINT /dev/vdb
```

This translates "the raw device `/dev/vdb` is saturated" into "the filesystem mounted at `/mnt/data-ingest` is saturated" — the actionable, reportable form of the finding. If the device were an LVM PV rather than a directly-mounted device, `lsblk`'s tree view would also show the intermediate VG/LV layer, letting you name the logical volume and its mountpoint correctly rather than stopping at the raw disk.

## Step 6: Write up the finding

```bash
sudo mkdir -p /opt/course/audit
sudo tee /opt/course/audit/io-report.txt > /dev/null <<'EOF'
device: /dev/vdb
pid: <PID from Step 4>
process: data-ingest-job
direction: write
mountpoint: /mnt/data-ingest
EOF
```

That file is the actual deliverable of this whole investigation — every command above exists to fill in one of these five values correctly.

## Verification

```bash
vmstat 1 5
# expect: elevated wa (%) sustained across samples 2-5

iostat -xz 1 5
# expect: one device with high %util and high await relative to others
# (whichever letter it lands on -- don't assume /dev/vdb)

sudo iotop -o -b -n 1
# expect: one process (data-ingest-job) clearly dominating WRITE throughput

lsblk -o NAME,FSTYPE,MOUNTPOINT
# expect: a real mountpoint (/mnt/data-ingest) on the device iostat flagged, not blank

cat /opt/course/audit/io-report.txt
# expect: device, pid, process, direction, mountpoint all filled in correctly
```

Because this lab is diagnostic rather than configuration-changing, "verification" here means confirming your conclusion is internally consistent: the device iostat flagged should be the same device lsblk maps to a real mountpoint, and the process iotop flagged should plausibly be a data-processing job matching the scenario description — then that conclusion is recorded in `io-report.txt`.

## Command Summary

```bash
vmstat 1 5
iostat -xz 1 5
sudo iotop -o
sudo iotop -o -b -n 3
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT
sudo mkdir -p /opt/course/audit
sudo tee /opt/course/audit/io-report.txt > /dev/null <<'EOF'
device: /dev/vdb
pid: <PID>
process: data-ingest-job
direction: write
mountpoint: /mnt/data-ingest
EOF
```
