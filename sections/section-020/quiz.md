# Section 020 Knowledge Check: Remote Filesystems

Test your understanding of FUSE layers, SSHFS mounting constraints, NFS server-side exports rules, and resilient client-side parameters.

---

## Scenario-Based Questions

### Question 1
You are using SSHFS to mount a directory from a database node onto your local system for log inspections. You run the command `sshfs root@db-node:/var/log /mnt/db-logs`. Although the mount succeeds, a background audit cronjob running as the system user `backup-agent` is unable to read the mounted files, returning `Permission Denied`. What is the cause of this failure?
*   **A)** SSHFS does not support directories owned by root.
*   **B)** SSHFS runs as a FUSE (Filesystem in User Space) driver, which by default locks the mount so it is *only* readable by the specific user who executed the mount.
*   **C)** The SSH port on the database node was closed immediately after mounting.
*   **D)** The user `backup-agent` does not have access to standard SSH keys.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Filesystems in User Space (FUSE), such as SSHFS, run in user memory space rather than inside the kernel. To protect system security, the FUSE subsystem strictly limits access to the active mount folder to the user who ran the `sshfs` command—not even the `root` superuser can read inside by default. To allow other system users or daemons to access the mount, you must explicitly enable the `-o allow_other` option.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because SSHFS has no constraints regarding root ownership of files.
    *   *Option C* is incorrect because an active mount would return a network timeout or I/O error, not a standard filesystem permission denied.
    *   *Option D* is incorrect because the local file permission error is enforced by the local VFS layer, not the remote SSH keys.
</details>

---

### Question 2
You are editing the `/etc/exports` file on your centralized file server to export a shared folder. You want to make `/data/assets` readable and writeable by client hosts in the subnet `10.10.40.0/24`, ensuring write data is safely written to disk before the server responds. Which entry is correctly formatted?
*   **A)** `/data/assets 10.10.40.0/24 (rw,async)`
*   **B)** `/data/assets 10.10.40.0/24(rw,sync,no_subtree_check)`
*   **C)** `10.10.40.0/24:/data/assets rw,sync`
*   **D)** `mount -t nfs -o rw,sync 10.10.40.0/24:/data/assets`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** NFS exports configuration files inside `/etc/exports` have a very strict syntax. The layout requires the absolute path on the server, a space, the whitelisted target subnet, and immediately followed by configuration options inside parentheses **with no space** between the subnet and the opening parenthesis. `rw` permits writing, `sync` guarantees writes are committed to stable disk storage before completing the transaction, and `no_subtree_check` improves performance and reliability.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because of the space before the parentheses (which causes NFS to interpret the options incorrectly or throw parsing warnings) and because `async` returns success before the data is committed to disk, risking data loss in power crashes.
    *   *Option C* is incorrect because it uses an invalid reverse syntax.
    *   *Option D* is incorrect because it is a client mount command, not an exports file configuration rule.
</details>

---

### Question 3
An application server connects to a central file vault using an NFS mount listed in its `/etc/fstab` table. The storage vault experiences a hardware crash and goes completely offline. When you log into the application server and run `df -h` or `ls /mnt/vault`, your shell terminal completely freezes. How do you prevent this system lockout?
*   **A)** Increase the CPU count on the application server so it can handle the network timeout threads.
*   **B)** Configure the NFS mount with the `soft` and `intr` (interruptible) parameters on the client.
*   **C)** Run `sudo exportfs -u` on the client server to force-disconnect the network interface.
*   **D)** Mount the NFS share over SSHFS instead to bypass the RPC daemon.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** By default, NFS mounts are "hard" mounts, meaning the client will retry the network connection indefinitely. If the server crashes, any filesystem query (like `df` or `ls`) will hang the querying shell process in an un-interruptible sleep state (`D` state), freezing your terminal. Mounting with the `soft` parameter allows the client to return an I/O error after a timeout, and `intr` allows you to kill hung shell processes using `Ctrl+C`.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because terminal hangs are caused by kernel wait queues, not CPU thread limits.
    *   *Option C* is incorrect because `exportfs` is an NFS server tool used to manage exports, not a client unmounting utility.
    *   *Option D* is incorrect because SSHFS has its own connection timeouts but does not replace enterprise-grade high-throughput NFS sharing.
</details>

---

### Question 4
After making modifications to `/etc/exports` on an active production NFS server, what is the most professional way to apply the new export rules without interrupting active clients currently reading from other directories?
*   **A)** Restart the entire server using `sudo reboot`.
*   **B)** Run `sudo systemctl restart nfs-server` to restart the daemon.
*   **C)** Run `sudo exportfs -arv` to reload the export configurations.
*   **D)** Run `sudo umount -a` to refresh all mounts.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** The `exportfs` utility manages NFS exports. The `-a` flag tells the tool to export or unexport all directories, `-r` re-exports all directories, and `-v` makes the output verbose. Running `sudo exportfs -arv` tells the kernel to parse `/etc/exports` and update its active exports table on the fly without restarting services or severing existing connections.
*   **Why others are incorrect:**
    *   *Options A and B* are highly disruptive and will drop active connections, causing active client transactions to fail or hang.
    *   *Option D* is incorrect because unmounting all devices on the server does not reload NFS export parameters and will crash running systems.
</details>

---

### Question 5
You are logged into a client machine and need to verify which exported directories are available for you to mount from an NFS server located at IP `10.10.40.10`. Which command should you run?
*   **A)** `sudo blkid 10.10.40.10`
*   **B)** `showmount -e 10.10.40.10`
*   **C)** `lsblk --net 10.10.40.10`
*   **D)** `cat /proc/mounts | grep 10.10.40.10`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The `showmount` command queries the mount daemon on a remote NFS server. The `-e` (exports) option instructs it to list all the directory paths exported by the server at that IP address, allowing you to verify exactly what is available before mounting.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `blkid` is used to list local block filesystem UUIDs, not query remote network nodes.
    *   *Option C* is incorrect because `lsblk` does not have a `--net` option and only queries local hardware block structures.
    *   *Option D* is incorrect because `/proc/mounts` only displays filesystems that are *already actively mounted* locally; it cannot query remote directories before they are connected.
</details>
