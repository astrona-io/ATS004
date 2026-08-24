# Section 060 Knowledge Check: Virtual Filesystems

Test your understanding of the VFS callback architecture, `/proc/meminfo` fields, file descriptor audit lists, and the sysctl interface.

---

## Scenario-Based Questions

### Question 1
You run the command `ls -l /proc` on a server and notice that many of the files inside show a size of `0` bytes, yet you can read them with `cat` and get multi-line text readouts. What is the cause of this behavior?
*   **A)** The files are corrupted and need to be repaired using `fsck`.
*   **B)** The directories represent a Virtual Filesystem (VFS) where file contents do not exist statically on physical disk sectors; instead, they are generated dynamically by the kernel on-the-fly inside system RAM whenever you query them.
*   **C)** The filesystem has been mounted as read-only.
*   **D)** Your user does not have permission to view file sizing metrics.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Files inside `/proc` and `/sys` do not reside on physical disk storage. They are virtual gates managed by the kernel's Virtual Filesystem (VFS) layer. When you run `cat` on a file like `/proc/meminfo`, VFS intercepts the request, runs an internal C callback function inside the kernel to collect active memory variables, and prints them to your shell as a plain-text stream. Because they are dynamic streams, they report a size of `0` bytes on disk.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because virtual filesystems cannot be corrupted or scanned by block repair utilities.
    *   *Option C* is incorrect because mount options do not affect the dynamic sizing attributes of kernel streams.
    *   *Option D* is incorrect because even the root user sees a size of `0` bytes for virtual files.
</details>

---

### Question 2
You are troubleshooting an application server running a high-volume network daemon. The application suddenly crashes and writes the error `java.io.IOException: Too many open files` to its log. What is the most effective command sequence to audit how many file handles this process currently has open?
*   **A)** `df -h | grep <PID>`
*   **B)** `sudo ls -l /proc/<PID>/fd/ | wc -l`
*   **C)** `cat /proc/meminfo | grep Files`
*   **D)** `sysctl -a | grep files`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Every running process has its own dedicated subdirectory under `/proc` named after its Process ID (PID). Inside, the subfolder `fd/` (File Descriptors) contains a list of symbolic links, one for every single resource (file, folder, socket, pipeline) the process currently holds open. Listing this folder (`ls -l`) and passing the stream to a line count tool (`wc -l`) calculates the exact active open file handles, helping you verify file-descriptor leaks.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `df -h` shows device storage capacities, not process file allocations.
    *   *Option C* is incorrect because `/proc/meminfo` tracks global RAM pools, not process-specific file handles.
    *   *Option D* is incorrect because sysctl views system-wide allocation limits, not the current usage of a specific process.
</details>

---

### Question 3
You want to temporarily enable IPv4 IP forwarding on your gateway server. You run the command `echo "1" | sudo tee /proc/sys/net/ipv4/ip_forward`. You reboot the server, and notice that forwarding has been disabled again. How do you make this change permanent?
*   **A)** Run the command with `sudo tee -p` to enable persistence.
*   **B)** Add the line `net.ipv4.ip_forward = 1` to the configuration file `/etc/sysctl.conf` (or a file under `/etc/sysctl.d/`).
*   **C)** Move the target file out of `/proc` and into `/etc/`.
*   **D)** Add `/proc/sys/net/ipv4/ip_forward` to `/etc/fstab` as a mount point.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Any modification made directly to files inside `/proc` or `/sys` (or written using `sysctl -w`) is **temporary** and exists only in system memory. When the system shuts down, these parameters are wiped clean. To make changes persist across reboots, you must record them inside `/etc/sysctl.conf` or a sub-map file inside `/etc/sysctl.d/`. During boot, the system reads these files and writes their values back to `/proc/sys` automatically.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `tee` flags do not provide system boot persistence.
    *   *Option C* is incorrect because you cannot relocate or delete virtual kernel files under `/proc`.
    *   *Option D* is incorrect because fstab maps block devices and filesystems, not individual sysctl parameters.
</details>

---

### Question 4
You need to verify the exact filesystem format and mount parameters currently active on your local root `/` partition. You notice that the output of `cat /proc/mounts` differs slightly from what is written inside `/etc/fstab`. Which file represents the absolute, live truth of the system mount state?
*   **A)** `/etc/fstab`, because it is the primary configuration mapping.
*   **B)** `/proc/mounts`, because it queries the kernel's active internal mount ledger in real time, showing exactly what is active.
*   **C)** `/etc/mtab`, because it logs all mount requests sequentially.
*   **D)** `/proc/sys/fs/mounts`, because it is a managed sysctl parameter.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `/etc/fstab` is merely an input configuration table defining what *should* be mounted at boot. `/etc/mtab` is a user-space file logging what was historically mounted. `/proc/mounts` is a direct window into the kernel's active internal mount table. If a drive was remounted as read-only by the kernel due to a write error, `/proc/mounts` will immediately reflect this live reality (`ro`), whereas `/etc/fstab` will continue to show `rw`.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because fstab is a passive configuration file and does not show active runtime mount states.
    *   *Option C* is incorrect because `/etc/mtab` is a user-space cache and can occasionally get out of sync with the kernel.
    *   *Option D* is incorrect because no such file exists under `sysctl` directories.
</details>

---

### Question 5
Which memory metric inside `/proc/meminfo` provides the most accurate estimate of how much memory is immediately available to launch new applications without invoking swap?
*   **A)** `MemFree`
*   **B)** `MemTotal`
*   **C)** `MemAvailable`
*   **D)** `Buffers`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** Many beginners look at `MemFree` to see available memory, which can be highly misleading. Linux aggressively uses empty RAM to cache active disk blocks (`Cached` and `Buffers`), which improves performance. This cache memory can be instantly reclaimed and freed if an application requests it. `MemAvailable` is a calculated kernel variable estimating `MemFree` plus reclaimable caches, providing the true metric of immediately assignable memory.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `MemFree` represents completely raw, unused memory, ignoring reclaimable caches and leading you to assume the system is out of memory when it isn't.
    *   *Option B* is incorrect because `MemTotal` lists total system physical RAM.
    *   *Option D* is incorrect because `Buffers` only shows the specific disk metadata cache allocations.
</details>
