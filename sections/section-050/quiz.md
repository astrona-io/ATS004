# Section 050 Knowledge Check: On-Demand Mounting (autofs)

Test your understanding of fstab network mount risks, autofs master map entries, custom sub-maps formatting, and automated timeout values.

---

## Scenario-Based Questions

### Question 1
Your company has several remote NFS mounts listed in `/etc/fstab` on an application server. During a power outage at the primary datacenter, the NFS storage host goes completely offline. When the application server reboots, it freezes during the boot sequence and refuses to reach a login shell. Why does this happen?
*   **A)** NFS mounts require a GUI desktop to load.
*   **B)** The kernel processes `/etc/fstab` synchronously during boot. If a network disk is unavailable, the mount command will block the boot sequence while waiting indefinitely for a TCP connection response.
*   **C)** The filesystem on the local root partition was corrupted by the NFS host crash.
*   **D)** The network card on the server was fried by the power outage.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Filesystems mapped inside `/etc/fstab` are mounted synchronously during system startup. If you list a remote network share (like NFS) in fstab, and that host is unreachable during boot, the local mount process will hang, repeatedly retrying the connection. This blocks the startup systemd units, freezing the boot sequence and preventing the server from reaching a login prompt.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because server systems run perfectly without GUI interfaces.
    *   *Option C* is incorrect because local filesystems are independent of remote networks.
    *   *Option D* is incorrect because even with a fried network card, the server would boot into a local shell unless blocked by fstab retries.
</details>

---

### Question 2
You are configuring `autofs`. You want `/etc/auto.master` to monitor the folder `/mnt/secure_vault`, and you want its sub-rules to be read from a file named `/etc/auto.vault` with a 2-minute inactivity timeout. Which line is correctly formatted for `/etc/auto.master`?
*   **A)** `/mnt/secure_vault  /etc/auto.vault  --timeout 120`
*   **B)** `/etc/auto.vault  /mnt/secure_vault  --timeout=120`
*   **C)** `/mnt/secure_vault  /etc/auto.vault  --timeout=120`
*   **D)** `mount -t autofs /mnt/secure_vault /etc/auto.vault`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** The syntax of the autofs master map `/etc/auto.master` is strictly defined: the monitored parent directory path, followed by a space or tab, the path to the sub-map configuration file, and optional flags like `--timeout=` (specified in seconds, e.g., `120` for 2 minutes).
*   **Why others are incorrect:**
    *   *Option A* is incorrect because autofs option parameters require an equals sign (`--timeout=120`), not a space.
    *   *Option B* is incorrect because it reverses the order of the parent path and the configuration file path.
    *   *Option D* is incorrect because it represents a raw command line, not an autofs configuration line.
</details>

---

### Question 3
You have configured `/etc/auto.master` to monitor `/mnt/auto` using sub-map `/etc/auto.custom`. You want `autofs` to trigger and mount an NFS export from `data-srv:/export/docs` to the folder `/mnt/auto/documents` as read-only. Which line is correctly written inside `/etc/auto.custom`?
*   **A)** `/mnt/auto/documents  -fstype=nfs,ro  data-srv:/export/docs`
*   **B)** `documents  -fstype=nfs,ro  data-srv:/export/docs`
*   **C)** `documents  mount -t nfs -o ro  data-srv:/export/docs`
*   **D)** `data-srv:/export/docs  -fstype=nfs,ro  documents`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** In an autofs sub-map (like `/etc/auto.custom`), the first parameter is the **relative folder key** (e.g., `documents`) which triggers the mount. You must **never** write the absolute parent path here, because autofs already knows it is monitoring `/mnt/auto` from the master map. This is followed by mount options starting with a hyphen (e.g., `-fstype=nfs,ro`), and finally the remote storage path (`data-srv:/export/docs`).
*   **Why others are incorrect:**
    *   *Option A* is incorrect because writing the absolute path `/mnt/auto/documents` will cause autofs to fail to resolve the directory and abort the trigger.
    *   *Option C* is incorrect because you write direct mount option strings, not raw CLI commands.
    *   *Option D* is incorrect because it reverses the order of the trigger key and the remote storage host.
</details>

---

### Question 4
You are setting up autofs on a client. To make sure the triggering directories exist, you run `sudo mkdir -p /mnt/auto/documents` before restarting the autofs service. When you navigate into `/mnt/auto/documents`, autofs fails to mount the remote share. Why did this fail?
*   **A)** Autofs requires you to assign the folder permissions of 777.
*   **B)** Manually creating the target subdirectory trigger interferes with the autofs daemon, which expects to dynamically create, overlay, and destroy these directories in memory.
*   **C)** Autofs can only mount to folders located directly under the `/` root directory.
*   **D)** You did not start the NFS service on the local client machine first.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** This is a classic autofs pitfall. The `automount` daemon acts as a virtual directory gatekeeper. It expects the parent monitored folder (`/mnt/auto`) to be empty. When a user requests `/mnt/auto/documents`, autofs intercepts this request and dynamically projects the subdirectory in system memory, mounting the remote disk over it. If you manually create the folder on disk first, the local folder blocks the VFS trigger, causing autofs to fail. Let autofs manage folder creation dynamically.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because folder permissions are handled dynamically by the mount options, not static 777 masks.
    *   *Option C* is incorrect because autofs supports mounting under any valid local directory path.
    *   *Option D* is incorrect because client nodes only need the NFS client utilities, not the server daemon.
</details>

---

### Question 5
You have finished reading logs inside `/mnt/auto/documents` and want the 5-minute inactivity timeout to run down and unmount the NFS share. However, after 10 minutes, you run `df -h` and see the share is still actively mounted. What is preventing the automount daemon from unmounting the drive?
*   **A)** The remote NFS server has locked the connection.
*   **B)** Your terminal shell's current working directory is set to `/mnt/auto/documents` (or an active process has an open file descriptor inside).
*   **C)** The autofs daemon has crashed.
*   **D)** The timeout must be explicitly activated using `systemctl trigger autofs`.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The autofs idle timer will only run down if the mount has **zero active references**. If you have a shell terminal open inside `/mnt/auto/documents` (your shell's CWD), or if a running background daemon has a log file held open on the drive, the kernel flags the device as active. You must navigate out of the mount (e.g., run `cd ~`) or close active file handles for the inactivity timer to start ticking down.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because unmounting is controlled entirely by the local client kernel, not the remote host.
    *   *Option C* is incorrect because a crashed daemon would leave the mount stale but would show up in systemctl status checks.
    *   *Option D* is incorrect because timeouts run automatically as background threads within the main autofs service.
</details>
