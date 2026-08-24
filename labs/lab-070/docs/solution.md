# Solution Guide (Offline & Exam Friendly)

This step-by-step guide explains how to identify disk I/O bottlenecks, determine if they are read- or write-bound, find the responsible process, and map the disk back to its filesystem mountpoint.

---

## Step 1: Check System-Wide I/O Wait

1. Run `vmstat` to get a system-wide diagnostic overview:
   ```bash
   vmstat 1 5
   ```
2. Look at the output. Ignore the first line (which shows averages since the system booted) and inspect lines 2 through 5.
3. Look at the **wa** column (under `cpu`). This shows the percentage of CPU time spent waiting for I/O.
   - A high value (e.g., above 20-30%) indicates a system-wide I/O bottleneck.
4. Look at the **bi** and **bo** columns (under `io`). These represent blocks received (read) and blocks written (write) per second.

---

## Step 2: Identify the Bottleneck Device

1. Run `iostat` to break down utilization per device:
   ```bash
   iostat -xz 1 5
   ```
   *If `iostat` is missing, install the `sysstat` package via your package manager.*
2. Ignore the first interval and look at the subsequent intervals.
3. Look at the **%util** (utilization percentage) and **await** (average I/O response time in milliseconds) columns.
   - Find the device that shows a high utilization (close to `100.00%`) alongside elevated `await` values (e.g., above 10-20ms).
   - Note the device name (for example, `/dev/vdb` or `/dev/vdc`). Let's assume it is `/dev/vdX`.

---

## Step 3: Determine Read-Bound vs. Write-Bound

Using the same `iostat -xz 1 5` output, look at the row for your bottleneck device `/dev/vdX`:

1. Compare **r/s** (read requests per second) and **rkB/s** (read kilobytes per second) against **w/s** (write requests per second) and **wkB/s** (write kilobytes per second).
2. If write numbers (w/s and wkB/s) are significantly larger than read numbers, the bottleneck is **write-bound** (often written as `write`). If read numbers are larger, it is **read-bound** (or `read`).

---

## Step 4: Find the Responsible Process

You need to identify which process is generating this high I/O traffic.

1. Run `iotop` in interactive mode to see active I/O processes:
   ```bash
   sudo iotop -o
   ```
   *The `-o` flag limits the view to only those processes that are actively performing I/O, reducing screen noise.*
2. Inspect the screen:
   - Identify the process with the largest and most sustained throughput in the `DISK WRITE` or `DISK READ` columns (matching your read-bound vs. write-bound finding from Step 3).
   - Note its **PID** and its **COMMAND** (for example, PID `1234` and command `data-ingest-job`).
3. If you want to print a non-interactive snapshot of active I/O processes instead of opening an interactive screen, run:
   ```bash
   sudo iotop -o -b -n 2
   ```

---

## Step 5: Map the Device to Its Mountpoint

1. List block devices along with their mountpoints:
   ```bash
   lsblk -o NAME,MOUNTPOINT
   ```
2. Locate your bottleneck device `/dev/vdX` in the list.
3. Read its entry in the `MOUNTPOINT` column (for example, `/mnt/data-ingest`).

---

## Step 6: Record Your Findings

1. Create the destination directory:
   ```bash
   sudo mkdir -p /opt/course/audit
   ```
2. Create and edit the report file `/opt/course/audit/io-report.txt` using your favorite text editor (e.g., `nano` or `vi`), or use `tee`:
   ```bash
   sudo tee /opt/course/audit/io-report.txt <<'EOF'
   device: /dev/vdX
   pid: <PID_OF_PROCESS>
   process: <PROCESS_NAME_OR_COMMAND>
   direction: <read_or_write>
   mountpoint: <MOUNTPOINT_PATH>
   EOF
   ```
   *Replace `/dev/vdX`, `<PID_OF_PROCESS>`, `<PROCESS_NAME_OR_COMMAND>`, `<read_or_write>`, and `<MOUNTPOINT_PATH>` with your exact findings.*

---

## Verification

Confirm your report is complete:

```bash
# Display the written report
cat /opt/course/audit/io-report.txt
```
*Ensure all 5 required keys (`device`, `pid`, `process`, `direction`, `mountpoint`) are defined and correct.*
