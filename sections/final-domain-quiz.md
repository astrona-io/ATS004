# LFCS Storage Domain Certification Quiz

Welcome to the Final Domain Certification Quiz for the **LFCS Storage** curriculum. This comprehensive test contains **20 high-signal, scenario-based system administration questions** covering all 18 modules inside our 8 storage sections. 

To simulate actual Linux Foundation exam pressure:
*   Answer all 20 questions without consulting external documentation or manual shell helpers.
*   Allow yourself a maximum of **30 minutes** to complete the entire test.
*   Once finished, scroll to the very bottom to check the **Audit and Review Key** to trace any incorrect answers back to their exact section and module chapters.

---

## The Exam Simulator

### Question 1
You are executing standard system maintenance and need to unmount the volume `/mnt/log-archive` to run disk scans. You run `sudo umount /mnt/log-archive` and the operating system rejects it with `umount: /mnt/log-archive: target is busy`. Which command should you run to immediately identify the command name and Process ID (PID) locking the mount point?
*   **A)** `sudo lsof -i :80`
*   **B)** `sudo fuser -mv /mnt/log-archive`
*   **C)** `df -h /mnt/log-archive`
*   **D)** `cat /proc/mounts | grep log-archive`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The `fuser` (File User) tool is specifically designed to show which Process IDs (PIDs) are actively using a directory or mount point. The `-m` (mount) flag tells `fuser` to resolve the entire mounted filesystem, and the `-v` (verbose) flag outputs detailed metadata, including the username, the process ID, the exact access type (e.g., current directory `c` or open file `f`), and the active command name.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `lsof -i :80` queries network processes listening on port 80, not filesystem mount locks.
    *   *Option C* is incorrect because `df -h` shows directory capacity metrics, but cannot audit active process handles.
    *   *Option D* is incorrect because `/proc/mounts` lists the kernel's active mount table options, not locking processes.
</details>

---

### Question 2
You are configuring a virtual machine that will house a 3.5 Terabyte local database storage drive. During the initial partitioning step, which standard partition table must you write to the raw disk, and why?
*   **A)** Write an MBR partition table, because it supports unlimited disk sizes.
*   **B)** Write a GPT partition table, because legacy MBR tables cannot address storage space past 2 Terabytes.
*   **C)** Write an MBR partition table using parted to take advantage of logical slices.
*   **D)** Write an XFS filesystem directly to the raw disk without a partition table.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Legacy MBR (Master Boot Record) partition tables use 32-bit logical block addressing, which limits the maximum addressable disk capacity to exactly 2 Terabytes (TB). For any disk larger than 2TB, you must use a GUID Partition Table (GPT) standard, which uses 64-bit addressing and easily supports massive disk arrays.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because MBR is limited to the 2TB ceiling.
    *   *Option C* is incorrect because changing the tool (`parted`) does not bypass MBR's built-in block addressing limits.
    *   *Option D* is incorrect because while possible, writing filesystems directly to raw disks (partition-less) is a non-standard practice that complicates recovery and partition management.
</details>

---

### Question 3
You have initialized LUKS encryption on `/dev/vdc1` using `cryptsetup luksFormat`. You now need to format the decrypted volume with an ext4 filesystem. What is the correct sequence of operations?
*   **A)** Format `/dev/vdc1` with ext4 directly, then open the volume using `cryptsetup open`.
*   **B)** Open the volume using `sudo cryptsetup open /dev/vdc1 vault_data` to map it, then format the mapped path `/dev/mapper/vault_data` with ext4.
*   **C)** Map the raw sectors using `mount -t luks`, then format the folder under `/mnt/`.
*   **D)** LUKS automatically formats the partition during the `luksFormat` step; no further actions are needed.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** LUKS encrypts block storage at the sector level. To make the encrypted drive usable, you must unlock and map the device using `cryptsetup open` to create a virtual decrypted block interface under `/dev/mapper/`. You then format (`mkfs.ext4`) and mount (`mount`) this virtual mapper target, never the raw partition.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because formatting the raw device directly overwrites and corrupts the LUKS headers, rendering the encrypted volume permanently broken.
    *   *Option C* is incorrect because `mount` does not support a native `luks` type and cannot map block devices.
    *   *Option D* is incorrect because `luksFormat` only writes the cryptographic keyslots and locks the drive; it does not generate filesystems.
</details>

---

### Question 4
Your gateway server experiences a sudden kernel panic and power crash during a write operation. Upon reboot, you suspect the local database partition `/dev/vdb2` has sustained indexing damage. Which command sequence is the safest and most correct way to scan and restore filesystem integrity?
*   **A)** Run `sudo fsck -y /dev/vdb2` while the partition is actively mounted and processing queries.
*   **B)** Unmount the partition using `sudo umount /dev/vdb2` first, then run `sudo fsck -y /dev/vdb2`.
*   **C)** Run `sudo tune2fs -c 1 /dev/vdb2` to automatically repair active memory blocks.
*   **D)** Format the partition again with `mkfs.ext4` to clear the errors.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Running `fsck` (Filesystem Consistency Check) on an active, mounted filesystem is extremely dangerous. As the kernel attempts to write files, `fsck`'s repairs will overwrite block allocations, causing severe and permanent metadata corruption. You must always unmount the drive first to guarantee raw block stability before running the check.
*   **Why others are incorrect:**
    *   *Option A* is highly dangerous and will corrupt the drive.
    *   *Option C* is incorrect because `tune2fs -c` sets mount count check thresholds; it does not repair blocks.
    *   *Option D* is incorrect because formatting destroys all existing database data.
</details>

---

### Question 5
You want to assign a human-readable volume label named `AUDIT_LOGS` to an existing local `ext4` partition `/dev/vdb1` so that it can be mounted reliably in fstab. Which command should you run?
*   **A)** `sudo tune2fs -L "AUDIT_LOGS" /dev/vdb1`
*   **B)** `sudo xfs_admin -L "AUDIT_LOGS" /dev/vdb1`
*   **C)** `sudo mkfs.ext4 -L "AUDIT_LOGS" /dev/vdb1`
*   **D)** `sudo mount -l "AUDIT_LOGS" /dev/vdb1`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: A**

*   **Why A is correct:** The `tune2fs` utility allows system administrators to adjust parameters and metadata on `ext2`, `ext3`, and `ext4` filesystems. The `-L` option sets the volume label string without touching your existing files.
*   **Why others are incorrect:**
    *   *Option B* is incorrect because `xfs_admin` only supports XFS filesystems and will fail on ext4 partitions.
    *   *Option C* is incorrect because running `mkfs` will create a brand new filesystem, wiping out all existing files on the partition.
    *   *Option D* is incorrect because `mount` options do not write metadata labels to the block headers.
</details>

---

### Question 6
You use SSHFS to mount a shared directory from an application server using `sshfs root@app-srv1:/data /app-srv1/data`. Although the mount works for your active terminal shell, local services running under system user accounts (like `www-data` or `nginx`) fail to read files inside `/app-srv1/data`, returning `Permission Denied`. How do you resolve this?
*   **A)** Change the folder permissions of the mountpoint to `777`.
*   **B)** Re-mount the directory using the option `-o allow_other` to permit other system users to access the FUSE mount.
*   **C)** Add the user accounts to the remote server's sudoers file.
*   **D)** Mount the share using NFS instead, as SSHFS is strictly single-user.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** SSHFS is a FUSE (Filesystem in User Space) driver. To prevent local privilege escalations, the Linux VFS strictly isolates FUSE mounts so they are only visible and accessible to the exact user who executed the mount command—even `root` is locked out by default. To share the mount with other local processes, you must mount it with the `-o allow_other` flag.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because VFS enforces FUSE isolation regardless of the folder's standard permission bits.
    *   *Option C* is incorrect because remote sudo privileges do not alter local FUSE mount permissions.
    *   *Option D* is incorrect because SSHFS natively supports multi-user access when correctly configured with `allow_other`.
</details>

---

### Question 7
You are editing the `/etc/exports` file on your centralized file server. You want to export `/var/data` as read-only to client hosts within the subnet `10.10.40.0/24`, ensuring that transaction writes are committed to disk before responding. Which line represents the correct configuration syntax?
*   **A)** `/var/data 10.10.40.0/24 (ro,sync)`
*   **B)** `/var/data 10.10.40.0/24(ro,sync,no_subtree_check)`
*   **C)** `10.10.40.0/24:/var/data ro,sync`
*   **D)** `mount -t nfs -o ro,sync 10.10.40.0/24:/var/data`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** NFS exports configuration has a highly strict syntax. The entry must display the server's absolute directory path, a space, the whitelisted client IP or subnet, and immediately followed by the options inside parentheses **with no space** between the subnet and the opening parenthesis. `no_subtree_check` is standard to prevent performance lags and path resolution errors.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because the space before the parentheses is invalid syntax in `/etc/exports` and will cause NFS to interpret option strings incorrectly.
    *   *Option C* is incorrect because it uses a reverse syntax.
    *   *Option D* is incorrect because it represents a client mounting command.
</details>

---

### Question 8
An application server connects to a central data vault using a standard NFS mount. During a severe network outage, the vault server crashes and goes offline. When administrators run shell commands that touch mounted directories, their terminal shells completely freeze. What client-side mount options in `/etc/fstab` prevent this lockout?
*   **A)** Mount the share using `async` and `noexec`.
*   **B)** Configure the NFS mount with the `soft` and `intr` flags.
*   **C)** Increase the network queue card limits using `sysctl`.
*   **D)** Mount the share as read-only (`ro`).

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** By default, NFS uses "hard" mounts, causing the client to retry network requests indefinitely if the server is down. This blocks any filesystem query in an un-interruptible sleep state, freezing shell processes. Specifying the `soft` flag allows the client to timeout and return an I/O error, and `intr` (interruptible) allows you to terminate hung queries using `Ctrl+C`.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `async` manages write caching, not network timeout states.
    *   *Option C* is incorrect because kernel networking queues do not alter NFS RPC hard-mount retry states.
    *   *Option D* is incorrect because read-only mounts will still hang indefinitely if the server is offline.
</details>

---

### Question 9
You are preparing raw disk storage using LVM. You have initialized `/dev/vdb` and `/dev/vdc` as LVM physical devices, grouped them into a VG pool named `data_pool`, and allocated a logical volume named `log_storage` of size 50G inside it. What is the correct command sequence?
*   **A)** `pvcreate /dev/vdb /dev/vdc` $\rightarrow$ `vgcreate data_pool /dev/vdb /dev/vdc` $\rightarrow$ `lvcreate -L 50G -n log_storage data_pool`
*   **B)** `lvcreate -n log_storage data_pool` $\rightarrow$ `vgcreate data_pool /dev/vdb` $\rightarrow$ `pvcreate /dev/vdb`
*   **C)** `mkfs.ext4 /dev/vdb` $\rightarrow$ `pvcreate /dev/vdb` $\rightarrow$ `vgcreate log_storage /dev/vdb`
*   **D)** `pvcreate data_pool` $\rightarrow$ `vgcreate log_storage data_pool` $\rightarrow$ `lvcreate /dev/vdb`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: A**

*   **Why A is correct:** LVM requires a strict bottom-up building block order: first, raw block devices are initialized as Physical Volumes (`pvcreate`); second, those PVs are aggregated into a Volume Group pool (`vgcreate`); finally, you carve out a Logical Volume (`lvcreate`) of a specific size (`-L`) and name (`-n`) from that VG pool.
*   **Why others are incorrect:**
    *   *Option B* is incorrect because you cannot allocate logical volumes before their parent groups and physical devices are registered.
    *   *Option C* is incorrect because formatting raw physical drives with filesystems before LVM initialization will overwrite block tables.
    *   *Option D* is incorrect because it uses incorrect command arguments.
</details>

---

### Question 10
You need to swap a failing physical disk `/dev/sdb` out of an active LVM Volume Group `vol1` without taking any database application offline. The disk currently contains allocated physical extents actively in use. Which command must you run to migrate the data blocks off the disk?
*   **A)** `sudo vgreduce vol1 /dev/sdb`
*   **B)** `sudo pvmove /dev/sdb`
*   **C)** `sudo pvremove /dev/sdb`
*   **D)** `sudo lvreduce -L -20G /dev/vol1/db`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The `pvmove` utility dynamically migrates allocated physical extents off a source physical volume and writes them to other available disks within the same Volume Group. This operation runs completely online, allowing you to clear `/dev/sdb` of all data blocks with zero database downtime.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because running `vgreduce` before migrating data blocks will fail or immediately corrupt your logical filesystems.
    *   *Option C* is incorrect because `pvremove` is used to wipe LVM labels from a disk, which can only be done *after* it has been removed from the VG.
    *   *Option D* is incorrect because it shrinks a logical volume container but does not vacate the physical blocks on `/dev/sdb`.
</details>

---

### Question 11
You have expanded an active Logical Volume from 10G to 20G using `sudo lvextend -L 20G /dev/vol1/data`. However, when you run `df -h`, your mounted ext4 partition continues to display its size as 10G. What step did you miss?
*   **A)** You must reboot the machine to apply the block boundaries.
*   **B)** You extended the volume container, but you have not yet expanded the filesystem database nested inside the volume using `resize2fs`.
*   **C)** The volume group `vol1` did not have enough physical extents.
*   **D)** You must unmount and format the drive again to clear the cache.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct (Vesey's Law):** A Logical Volume acts like a virtual hard drive container, and inside it resides your filesystem (like ext4 or XFS). Running `lvextend` only resizes the container boundary. To make the filesystem database aware of the new space, you must grow the filesystem itself. For ext4, you run `resize2fs /dev/vol1/data`. For XFS, you run `xfs_growfs /mount/point`.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because Linux filesystem expansions can be performed entirely online with zero reboots or downtime.
    *   *Option C* is incorrect because if the VG was out of extents, `lvextend` would have aborted with an error during execution.
    *   *Option D* is incorrect because formatting would destroy all your existing data.
</details>

---

### Question 12
Under heavy processing load, a database node runs completely out of physical RAM. To protect itself from a crash, the kernel invokes the Out-of-Memory (OOM) Killer. How does the kernel determine which process is terminated?
*   **A)** It kills the oldest process on the system to free up resources.
*   **B)** It calculates a score (`0` to `1000`) for every process, heavily weighting the percentage of physical memory the process consumes, and kills the process with the highest score.
*   **C)** It terminates the terminal shell of the user running the highest number of background threads.
*   **D)** It always targets the standard database daemons (`mysqld` or `postgres`) by default.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The kernel's OOM Killer uses a scoring algorithm based primarily on the percentage of physical RAM a process consumes. The process using the largest percentage of memory receives the highest score and is targeted first for termination to free up maximum RAM instantly. You can adjust process vulnerability using `/proc/<PID>/oom_score_adj`.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because process age has no bearing on OOM scoring.
    *   *Option C* is incorrect because shell processes consume very little RAM and are rarely OOM targets.
    *   *Option D* is incorrect because the kernel has no built-in bias against database processes; databases are targeted simply because they consume the largest pools of memory.
</details>

---

### Question 13
You create a swap file at `/swapfile` using `fallocate` and format it with `mkswap`. When you attempt to enable it using `sudo swapon /swapfile`, the command fails with a severe warning and halts. Why did the kernel refuse to activate the swap file?
*   **A)** The file was not registered in `/etc/fstab` first.
*   **B)** The file permissions are not restricted to root-only read-write access (`0600`).
*   **C)** The filesystem type of the parent partition is ext4, which does not support swap files.
*   **D)** You did not run `chown root:root /swapfile`.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Swap files contain raw unencrypted pages of active physical memory, which often include plaintext passwords, private session keys, and database records. If the swap file is readable by other users (e.g., standard `644` permissions), it presents a massive security vulnerability. The kernel strictly enforces a security check: swap files **must** have permissions restricted to root-only access (`0600`) or they will be rejected by `swapon`.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because fstab is used for boot persistence, but is not required to run `swapon` manually.
    *   *Option C* is incorrect because ext4 fully supports swap files.
    *   *Option D* is incorrect because files created by the root user are already owned by root.
</details>

---

### Question 14
You want to configure `/etc/fstab` so that the fast physical swap partition `/dev/vdb1` is preferred by the kernel over the slow swap file `/swapfile` fallback. How should you write their fstab parameters?
*   **A)** Map the partition with `pri=5` and the file with `pri=10`.
*   **B)** Map the partition with `pri=10` and the file with `pri=5`.
*   **C)** List the partition above the file; the kernel always processes swap areas sequentially.
*   **D)** Specify `defaults,preferred` on `/dev/vdb1`.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** In `/etc/fstab`, swap areas are prioritized using the `pri=` option. The kernel writes to the swap area with the highest priority number first, only cascading to lower-priority swap zones once the primary area is saturated. Tuning the fast partition to `pri=10` and the fallback file to `pri=5` guarantees optimal I/O scheduling.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because it reverses the priority, forcing the slow swap file to be exhausted first.
    *   *Option C* is incorrect because if priorities are equal or omitted, the kernel stripes swap writes across both areas simultaneously in a round-robin format.
    *   *Option D* is incorrect because `preferred` is an invalid fstab parameter.
</details>

---

### Question 15
You are configuring `autofs`. You want `/etc/auto.master` to monitor the parent directory `/mnt/auto` and read specific subfolder rules from `/etc/auto.custom` with a 5-minute inactivity timeout. Which line represents the correct configuration?
*   **A)** `/mnt/auto  /etc/auto.custom  --timeout 300`
*   **B)** `/mnt/auto  /etc/auto.custom  --timeout=300`
*   **C)** `/etc/auto.custom  /mnt/auto  --timeout=300`
*   **D)** `mount -t autofs /mnt/auto /etc/auto.custom`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The autofs master map file `/etc/auto.master` requires a strict three-parameter format: the absolute parent directory path being monitored, followed by a space, the absolute path to the sub-map configuration file, and optional flags like `--timeout=` (specified in seconds, e.g., `300` for 5 minutes).
*   **Why others are incorrect:**
    *   *Option A* is incorrect because option parameters require an equals sign (`--timeout=300`), not a space.
    *   *Option C* is incorrect because it reverses the order of the parent directory and the configuration file.
    *   *Option D* is incorrect because it represents a raw CLI mount command.
</details>

---

### Question 6
You are writing rules inside an `autofs` sub-map file `/etc/auto.custom` to mount a remote NFS share (`data-srv:/export/shared`) to the directory `/mnt/auto/shared`. What is the correct format for this sub-map line?
*   **A)** `/mnt/auto/shared  -fstype=nfs,ro  data-srv:/export/shared`
*   **B)** `shared  -fstype=nfs,ro  data-srv:/export/shared`
*   **C)** `shared  mount -t nfs -o ro  data-srv:/export/shared`
*   **D)** `data-srv:/export/shared  -fstype=nfs,ro  shared`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Autofs sub-maps define relative directories (triggers) under the master parent directory. Because the master map already specifies `/mnt/auto`, you must **only** write the relative trigger folder name (e.g., `shared`). Writing the absolute path will break directory resolution. This is followed by options starting with a hyphen, and finally the remote storage path.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because writing the absolute parent path `/mnt/auto/shared` will cause the automount daemon to abort the trigger.
    *   *Option C* is incorrect because you write mount parameter strings, not raw CLI commands.
    *   *Option D* is incorrect because it reverses the order of the trigger key and the remote host.
</details>

---

### Question 17
You are auditing system RAM metrics. Which field inside `/proc/meminfo` provides the most accurate estimate of how much memory is immediately available to launch new applications without invoking swap?
*   **A)** `MemFree`
*   **B)** `MemTotal`
*   **C)** `MemAvailable`
*   **D)** `Buffers`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** Linux aggressively uses free memory to cache disk blocks (`Cached` and `Buffers`) to optimize system performance. This cache memory can be instantly reclaimed and freed if a new application requests it. `MemAvailable` is a calculated kernel variable estimating `MemFree` plus reclaimable caches, providing the true metric of available physical memory.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `MemFree` only displays completely raw, untouched memory blocks, ignoring reclaimable caches.
    *   *Option B* is incorrect because `MemTotal` lists total system physical RAM.
    *   *Option D* is incorrect because `Buffers` only shows specific disk metadata allocations.
</details>

---

### Question 18
An application server running a Java daemon crashes and writes the error `java.io.IOException: Too many open files` to its log. Which command will count the exact number of active open file descriptors currently allocated to this process PID?
*   **A)** `df -h /proc/<PID>`
*   **B)** `sudo ls -l /proc/<PID>/fd/ | wc -l`
*   **C)** `cat /proc/meminfo | grep files`
*   **D)** `sysctl fs.file-max`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Inside `/proc`, every running process has a directory named after its PID. The subfolder `fd/` contains symbolic links, one for every single file descriptor, socket, or pipeline the process currently holds open. Listing this folder (`ls -l`) and passing it to a line count utility (`wc -l`) calculates the exact active allocated file handles.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `df` audits disk capacity, not process file allocations.
    *   *Option C* is incorrect because `/proc/meminfo` tracks system-wide memory, not process-specific file handlers.
    *   *Option D* is incorrect because `file-max` represents system-wide limits, not active process-level allocations.
</details>

---

### Question 19
You suspect a disk performance bottleneck on raw block device `/dev/vdc`. You run `iostat -xz 1` to inspect device operations. Which column in the output represents the average wait time (in milliseconds) for an I/O request to be completed?
*   **A)** `r/s`
*   **B)** `%util`
*   **C)** `await`
*   **D)** `wkB/s`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** In `iostat` extended statistics, the `await` column represents the average time (in milliseconds) that I/O requests issued to the device took to complete, including both queue wait times and physical block service times. Any `await` over 15-20ms indicates a slow disk bottleneck.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `r/s` shows read requests completed per second.
    *   *Option B* is incorrect because `%util` shows device busy percentage, not execution latency.
    *   *Option D* is incorrect because `wkB/s` shows write throughput volume in kilobytes per second.
</details>

---

### Question 20
You are preparing a sorted capacity report of top-level directories under `/`. You want to recursively measure directory sizes in human-readable units, but you must ensure the search strictly ignores separate mounted disks and network shares to prevent double-counting. Which command should you run?
*   **A)** `sudo du -sh / | sort -hr`
*   **B)** `sudo du -xh -d 1 / | sort -hr`
*   **C)** `sudo du -h -d 2 / | sort -n`
*   **D)** `sudo du --max-depth=1 /etc`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The `du` utility recursively measures sizes. The `-x` (or `--one-file-system`) flag is critical because it forces the tool to skip any directories that reside on separate mount points (like network shares or backup drives). The `-h` flag formats human units, `-d 1` restricts depth to top-level directories, and `sort -hr` reverse-sorts them numerically in descending order.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because it lacks the `-x` flag (risking double-counting external drives) and uses `-s` (which summaries `/` to a single line, hiding all subfolders).
    *   *Option C* is incorrect because depth `2` clutters the output, and `sort -n` fails to sort human suffixes correctly.
    *   *Option D* is incorrect because it targets `/etc` instead of the root directory `/`.
</details>

---

## Audit and Review Key

Check your score and use this review matrix to trace any incorrect answers back to their exact section and module chapters:

| Question | Targeted Storage Competency | Review Chapter |
| :--- | :--- | :--- |
| **Q1** | Evicting processes blockading unmounts | **[Section 010, Module 01](./section-010/module-01/course.md)** |
| **Q2** | Partition table standards (GPT vs. MBR) | **[Section 010, Module 02](./section-010/module-02/course.md)** |
| **Q3** | LUKS Block Encryption & mapper formatting | **[Section 010, Module 03](./section-010/module-03/course.md)** |
| **Q4** | Filesystem integrity scans (`fsck` constraints) | **[Section 010, Module 04](./section-010/module-04/course.md)** |
| **Q5** | Labeling filesystems (`tune2fs`) & UUID fstab entries | **[Section 010, Module 04](./section-010/module-04/course.md)** |
| **Q6** | User-space mounting restrictions with SSHFS | **[Section 020, Module 01](./section-020/module-01/course.md)** |
| **Q7** | NFS exporting configuration & `/etc/exports` rules | **[Section 020, Module 02](./section-020/module-02/course.md)** |
| **Q8** | Preventing stale network mount locks (`soft,intr`) | **[Section 020, Module 02](./section-020/module-02/course.md)** |
| **Q9** | Creating LVM PV, VG, and LV devices | **[Section 030, Module 01](./section-030/module-01/course.md)** |
| **Q10** | Live LVM physical extent migrations (`pvmove`) | **[Section 030, Module 02](./section-030/module-02/course.md)** |
| **Q11** | Dynamic filesystem expansions vs LV sizes | **[Section 030, Module 02](./section-030/module-02/course.md)** |
| **Q12** | Virtual memory allocation limits & OOM-killer logic | **[Section 040, Module 01](./section-040/module-01/course.md)** |
| **Q13** | Swap file sizing, initialization, & file permissions | **[Section 040, Module 01](./section-040/module-01/course.md)** |
| **Q14** | Dedicated swap partitions & priority scheduling | **[Section 040, Module 02](./section-040/module-02/course.md)** |
| **Q15** | Dynamic automount daemon & auto.master maps | **[Section 050, Module 01](./section-050/module-01/course.md)** |
| **Q16** | NFS automounting custom sub-maps & timeout rules | **[Section 050, Module 02](./section-050/module-02/course.md)** |
| **Q17** | Global kernel memory auditing (`/proc/meminfo`) | **[Section 060, Module 01](./section-060/module-01/course.md)** |
| **Q18** | Auditing process open file descriptors (`/proc/fd`) | **[Section 060, Module 01](./section-060/module-01/course.md)** |
| **Q19** | Analyzing wait latencies & queue waits (`iostat`) | **[Section 070, Module 01](./section-070/module-01/course.md)** |
| **Q20** | Recursive filesystem sizing (`du` and `-x` flag) | **[Section 080, Module 01](./section-080/module-01/course.md)** |
