# Section 070 Knowledge Check: Storage Performance

Test your understanding of disk saturation, queue wait latencies, real-time process I/O readouts, and file handle auditing.

---

## Scenario-Based Questions

### Question 1
You are troubleshooting a database server that has become slow. You run `top` and notice that CPU idle time is 60%, but the `%wa` (I/O Wait) metric is sitting at 35%. What does this tell you about the system bottleneck?
*   **A)** The database has run out of memory and has started swapping.
*   **B)** The server is heavily compute-bound; you must add more CPU cores.
*   **C)** The CPU is completely idle 35% of the time because it is blocked, waiting for slow disk read/write storage transactions to complete.
*   **D)** The network interface card is dropping packets.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** The `%wa` (I/O Wait) metric represents the percentage of time that the CPU was completely idle *while there was an outstanding disk I/O transaction in progress*. A high I/O wait indicates that your CPU is incredibly fast and wants to process work, but is throttled because it is waiting for slow disk blocks to read or write. Adding CPU cores will not solve this; you must optimize database queries, add memory cache, or upgrade to faster block storage.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because swap usage would show up in high memory allocations and `swpd` activity, not directly in raw disk I/O wait percentages alone.
    *   *Option B* is incorrect because high wait indicates the CPU is *idle*, not CPU-saturated.
    *   *Option D* is incorrect because network delays do not contribute to CPU disk I/O wait statistics.
</details>

---

### Question 2
You suspect a local disk `/dev/vdc` is saturated. You run `iostat -xz 1` to inspect extended disk statistics. Which column in the output represents the average total latency (in milliseconds) for an I/O request to be completed?
*   **A)** `r/s`
*   **B)** `%util`
*   **C)** `await`
*   **D)** `wkB/s`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** In `iostat -xz` output, the `await` column represents the average time (in milliseconds) that I/O requests issued to the device took to complete. This includes both the time the request spent waiting in the device queue and the physical service time of the disk. On production systems, an `await` higher than 15-20ms is generally considered slow for spinning hard drives; SSDs should ideally remain under 1-2ms.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `r/s` shows the number of read requests completed per second.
    *   *Option B* is incorrect because `%util` shows the percentage of time the device was busy, which can show 100% saturation even if individual latencies are low.
    *   *Option D* is incorrect because `wkB/s` shows write throughput volume in kilobytes per second.
</details>

---

### Question 3
An application is generating high disk writes, and you need to find its Process ID (PID). Which command is best suited to display a real-time, interactive, `top`-like interface that lists *only* the processes actively generating disk I/O throughput?
*   **A)** `sudo top`
*   **B)** `sudo iotop -o`
*   **C)** `iostat -xz 1`
*   **D)** `lsof -i`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The `iotop` command monitors I/O usage information output by the Linux kernel. Running it with the `-o` (only) flag interactive filter restricts the listing to *only* display processes or threads actually performing I/O at that exact second, allowing you to quickly spot the exact PID generating the disk writes.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because standard `top` displays CPU and RAM metrics; it does not display disk I/O read/write throughput per process.
    *   *Option C* is incorrect because `iostat` shows aggregate statistics per raw disk device, but cannot show individual process PIDs.
    *   *Option D* is incorrect because `lsof -i` is used to list active network sockets, not disk read/write throughput.
</details>

---

### Question 4
You have identified a rogue backup daemon under PID `5012` that is saturating your disk inside `iotop`. You want to find the exact file paths on disk that this process is currently writing to. Which command should you execute?
*   **A)** `sudo lsof -p 5012`
*   **B)** `sudo fuser -mv 5012`
*   **C)** `df -h | grep 5012`
*   **D)** `cat /proc/sys/fs/file-max`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: A**

*   **Why A is correct:** The `lsof` (List Open Files) utility lists information about files opened by processes. Running `sudo lsof -p <PID>` instructs the tool to query the kernel and return a precise list of every single file descriptor, directory, library, and block device currently held open by that specific Process ID, helping you identify exactly what files are being written.
*   **Why others are incorrect:**
    *   *Option B* is incorrect because `fuser` is used to map a *directory path* to PIDs, not query a PID to list its open files.
    *   *Option C* is incorrect because `df` maps devices to mount sizes, not process ids.
    *   *Option D* is incorrect because `file-max` represents system-wide open file limits, not process-level allocations.
</details>

---

### Question 5
You are diagnosing a slow-performing database partition. Your `iostat -xz 1` output shows a high volume of writes (`wkB/s` is high) but very low reads, and the device wait time is high. You run `iotop -o` and confirm that a log-rotation cron daemon is actively writing log files. What type of workload is this?
*   **A)** Read-bound
*   **B)** Write-bound
*   **C)** CPU-bound
*   **D)** Network-bound

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** A workload is considered *write-bound* if its performance is bottlenecked by the speed at which it can save new data to physical disk blocks. Since the stats show high `wkB/s` (write volume), low reads, and a logging process writing files, the disk I/O queue is saturated by writes.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because a read-bound workload would show high read request speeds (`rkB/s`).
    *   *Option C* is incorrect because high wait indicates the CPU is idle, not compute-saturated.
    *   *Option D* is incorrect because local disk logging does not saturate network interfaces.
</details>
