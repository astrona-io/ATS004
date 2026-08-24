# Section 040 Knowledge Check: Swap Space Management

Test your understanding of the OOM killer, swap file permissions security, swap partition setups, and priority scheduling maps inside fstab.

---

## Scenario-Based Questions

### Question 1
You are running a minimal database node that has no swap configured. Under high load, the MySQL service suddenly terminates. When you inspect `/var/log/syslog` or run `dmesg`, you see the message: `Out of memory: Kill process 2014 (mysqld) score 850 or sacrifice child`. Why did the kernel select the database process to kill?
*   **A)** The database was using an invalid configuration file format.
*   **B)** The Out-of-Memory (OOM) Killer tracks a score based on memory footprint percentage; the process using the highest memory percentage has the highest score and is sacrificed first.
*   **C)** The MySQL daemon was corrupted and crashed on its own.
*   **D)** The fstab file was missing a swap partition mapping.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** When a system completely exhausts its physical RAM and has no swap zone configured, it enters a critical state. To keep the server alive, the kernel invokes the OOM Killer. The OOM Killer calculates a score (`0` to `1000`) for every active process, heavily weighting the percentage of RAM the process consumes. The process with the highest memory consumption (like a database) gets the highest score and is sacrificed first to free up memory instantly.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because config format errors cause start failures, not active kernel OOM kills.
    *   *Option C* is incorrect because the log explicitly states the kernel initiated the kill command (`Kill process`).
    *   *Option D* is incorrect because while missing swap *leads* to the RAM exhaustion, the OOM scoring is what determines which process is selected for termination.
</details>

---

### Question 2
You create a swap file at `/swapfile` using `fallocate` and format it with `mkswap`. However, when you run `sudo swapon /swapfile`, the command fails with a permission warning and the kernel refuses to activate it. What critical security step did you miss?
*   **A)** You did not run `chown root:root /swapfile`.
*   **B)** You did not set permissions on the file to `600` (read-write by owner root only).
*   **C)** You did not add the swap file to the LVM database.
*   **D)** You did not format the file with ext4 first.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Swap space contains raw, unencrypted fragments of active system memory dumped on the fly. This includes active plaintext passwords, cryptographic private keys, and user sessions. If the swap file's permissions are readable by other users (e.g., standard `644`), any user on the system could read the file and extract credentials. The kernel strictly enforces a security policy: swap files **must** be restricted to root-only access (`chmod 600`).
*   **Why others are incorrect:**
    *   *Option A* is incorrect because files created by root are already owned by root.
    *   *Option C* is incorrect because LVM is a block layer virtualizer and does not manage standard swap files.
    *   *Option D* is incorrect because `mkswap` formats the file directly with a swap header; formatting it with ext4 first would be overwritten and is invalid.
</details>

---

### Question 3
What is the advantage of using a dedicated **Swap Partition** over a standard **Swap File**?
*   **A)** Swap partitions do not consume any space on your physical drive.
*   **B)** Swap partitions bypass the filesystem directory database and write blocks directly to raw sectors, offering slightly faster read/write times.
*   **C)** Swap partitions automatically encrypt all system memory blocks.
*   **D)** Swap partitions can be easily emailed to another server for migration.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** A swap file resides on an active filesystem (such as ext4 or XFS). When the kernel writes to a swap file, it must translate the blocks through the filesystem's indexing database. A swap partition is a raw block slice that bypasses this filesystem overhead entirely, allowing the kernel to read and write memory pages straight to raw disk sectors.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because partitions consume raw physical blocks on your drive.
    *   *Option C* is incorrect because standard swap partitions are written in plain text unless encrypted with tools like `dm-crypt`.
    *   *Option D* is incorrect because raw partitions are block devices, not portable files.
</details>

---

### Question 4
You have a fast physical NVMe SSD partition (`/dev/nvme0n1p1`) and a slow spinning hard drive fallback swap file (`/swapfile`). You want the kernel to exhaust the fast partition completely before writing any memory blocks to the slow file. How should you format their entries in `/etc/fstab`?
*   **A)** Map the partition with `pri=5` and the file with `pri=10`.
*   **B)** Map the partition with `pri=10` and the file with `pri=5`.
*   **C)** List the partition above the file; the kernel always processes fstab sequentially from top to bottom.
*   **D)** Enable the swappiness value of `100` on the partition.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** In `/etc/fstab`, swap areas are scheduled according to their priority parameter (`pri=`). The kernel evaluates active swap areas starting with the highest priority number first, only falling back to lower-priority numbers once the primary area is saturated. Setting the fast NVMe partition to `pri=10` and the slow file to `pri=5` guarantees the NVMe disk is used first.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because it reverses the priority, forcing the slow file to be exhausted first.
    *   *Option C* is incorrect because if priorities are equal or omitted, the kernel defaults to round-robin striping across both areas simultaneously, regardless of fstab line order.
    *   *Option D* is incorrect because swappiness is a system-wide kernel variable (tuned via sysctl), not a per-partition fstab parameter.
</details>

---

### Question 5
Which command should you run to view a clean, active list of all currently enabled swap areas, including their types, sizes, and priorities?
*   **A)** `free -h`
*   **B)** `swapon --show`
*   **C)** `sudo blkid`
*   **D)** `cat /proc/meminfo`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** While `free -h` displays the total combined capacity of active swap, running `swapon --show` (or reading the virtual file `cat /proc/swaps`) lists each active swap file and partition individually, clearly displaying their type, size, amount used, and active fstab scheduling priority.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `free -h` only shows total aggregate swap metrics, not individual priorities or file paths.
    *   *Option C* is incorrect because `blkid` shows filesystem types but cannot audit whether a swap partition is currently enabled or active in memory.
    *   *Option D* is incorrect because `/proc/meminfo` lists system-wide RAM metrics but does not list swap paths and priorities.
</details>
