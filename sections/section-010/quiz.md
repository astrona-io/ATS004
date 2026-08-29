# Section 010 Knowledge Check: Local Storage & Forensics

Test your understanding of partition tables, encryption mapping, filesystem integrity repairs, active process forensics, `/etc/fstab` entries, and systemd mount/automount units.

---

## Scenario-Based Questions

### Question 1
You run the command `sudo umount /mnt/backup` and the kernel returns `umount: /mnt/backup: target is busy`. You immediately run `sudo fuser -mv /mnt/backup` and see the following output:
```text
                     USER        PID ACCESS COMMAND
/mnt/backup:         root       2054 ..c..  rsync
```
What does the access indicator `c` mean, and how should you professionally resolve this lock?
*   **A)** It means the process has an open file descriptor (`f`). Run `sudo kill -9 2054` immediately to release the lock.
*   **B)** It means the process is executing from the drive (`e`). You must stop the service using systemctl.
*   **C)** It means the process's current working directory is set inside the mount (`c`). Send a polite `kill -15 2054` first, and if it fails to exit, escalate to `kill -9 2054`.
*   **D)** It means your terminal session is holding the lock. Run `cd ~` to leave the directory.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** The access character `c` indicates that the process's current working directory (CWD) is set inside the `/mnt/backup` directory tree. Attempting to unmount a filesystem while a process is actively sitting inside it will fail with a busy lock. The correct administrative response is to signal the process to exit cleanly using `SIGTERM` (`kill -15`), and escalate to `SIGKILL` (`kill -9`) only if it hangs.
*   **Why others are incorrect:** 
    *   *Option A* is incorrect because a force-kill (`-9`) is an extreme action that should not be used as a first response, and `c` does not stand for open file descriptor (which is represented as `f`).
    *   *Option B* is incorrect because `e` stands for executable, not `c`.
    *   *Option D* is incorrect because the process holding the lock is `rsync` running as root under PID 2054, not your shell.
</details>

---

### Question 2
You are partitioning a brand new 4 Terabyte physical SSD array to hold enterprise log data. Which partition table standard should you write to the disk, and what tool is best suited to script this partition creation?
*   **A)** Write an MBR partition table using `fdisk`, as it is highly compatible with all Linux versions.
*   **B)** Write a GPT partition table using `parted`, since MBR cannot address space past 2 Terabytes.
*   **C)** Write an MBR partition table using `parted` to take advantage of extended logical blocks.
*   **D)** Write a GPT partition table using `fsck` to verify the sector boundaries.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Legacy MBR partition tables are limited to addressing a maximum of 2 Terabytes of disk space and a maximum of 4 primary partitions. For a 4TB drive, a GPT (GUID Partition Table) must be written. `parted` is the industry-standard tool for scripting partition operations from the command line.
*   **Why others are incorrect:**
    *   *Options A and C* are incorrect because MBR cannot address or access any blocks past the 2TB boundary, rendering half of the 4TB drive completely useless.
    *   *Option D* is incorrect because `fsck` is a filesystem checker and repair utility; it cannot write partition tables or modify device block boundaries.
</details>

---

### Question 3
You have run `sudo cryptsetup luksFormat /dev/vdb1` and successfully set a secure passphrase. What is the next logical step you must take to make this encrypted device usable for file storage?
*   **A)** Run `sudo mkfs.ext4 /dev/vdb1` to format the raw sectors with a filesystem.
*   **B)** Run `sudo mount /dev/vdb1 /mnt/secure` to mount the drive directly to your directory tree.
*   **C)** Run `sudo cryptsetup open /dev/vdb1 secure_vault` to map the unlocked partition, then format `/dev/mapper/secure_vault`.
*   **D)** Run `sudo tune2fs -L "SECURE" /dev/vdb1` to label the drive.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** Once LUKS is formatted on a raw partition, its contents are completely scrambled. To write files, you must decrypt and map the block layer to a virtual decrypted device mapper path using `cryptsetup open`. You then format and mount the virtual mapped path under `/dev/mapper/`.
*   **Why others are incorrect:**
    *   *Options A, B, and D* are incorrect because running filesystems or metadata actions directly on the raw encrypted partition (`/dev/vdb1`) will corrupt and overwrite the critical LUKS headers, rendering the encrypted volume permanently unrecoverable.
</details>

---

### Question 4
You need to verify the filesystem integrity of `/dev/vdb1`. When you run `sudo fsck -y /dev/vdb1`, the kernel immediately displays a severe warning and halts the execution. What is the cause of this warning?
*   **A)** The `-y` flag is an invalid option; you must run `fsck` interactively.
*   **B)** The `/dev/vdb1` partition is currently mounted. Running `fsck` on an active mount can destroy filesystem tables.
*   **C)** The filesystem type of `/dev/vdb1` is XFS, which does not support integrity checks.
*   **D)** The partition does not contain any errors, so the kernel skipped the check.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Running `fsck` (Filesystem Consistency Check) on an active, mounted partition is highly dangerous. As the kernel and applications write data, `fsck`'s repairs will conflict with live writes, resulting in complete, irreversible metadata corruption. The kernel halts safety checks on mounted devices to protect your storage.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `-y` is a perfectly valid option that automatically answers "yes" to all repair prompts.
    *   *Option C* is incorrect because while XFS uses `xfs_repair` instead of standard fsck, the safety lockout applies to all mounted journaling filesystems.
    *   *Option D* is incorrect because a clean filesystem scan would simply report a successful, clean state rather than a severe system warning.
</details>

---

### Question 5
You are editing `/etc/fstab` to permanently mount a secondary local backup disk. Why is using a device UUID (e.g., `UUID=1234-abcd`) preferred over using the standard device block path (e.g., `/dev/vdb`)?
*   **A)** UUIDs are processed faster by the kernel during the boot sequence, reducing startup times.
*   **B)** Standard device paths like `/dev/vdb` are dynamically assigned by the kernel at boot and can swap if hardware configuration changes.
*   **C)** Standard paths like `/dev/vdb` do not support journaling filesystems like ext4.
*   **D)** UUIDs automatically unlock LUKS encrypted partitions without requiring a passcode.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Kernel drive names (such as `/dev/vdb` or `/dev/vdc`) are not guaranteed to be stable across reboots. If you plug in a new USB drive, storage card, or update your virtual hypervisor, the order in which disks are initialized can change. If `/etc/fstab` uses static device paths, it might mount the wrong disk to your critical system folder. UUIDs are tied to the filesystem metadata and remain constant regardless of physical order.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because UUID lookups actually add a tiny fraction of a second during boot (though negligible) to resolve the block tables.
    *   *Option C* is incorrect because block paths support any filesystem format.
    *   *Option D* is incorrect because UUIDs do not handle decryption or bypass key inputs.
</details>

---

## Persistent & On-Boot Mounting (Modules 5–6)

### Question 6
A server has an internal data disk added to `/etc/fstab` as `/dev/sdb1  /data  ext4  defaults  0  2`. After a technician installs a second internal disk and reboots, the machine drops to an emergency shell. What is the most likely cause?
*   **A)** ext4 filesystems cannot be listed in `/etc/fstab`.
*   **B)** The new disk changed the kernel device ordering, so `/dev/sdb1` now refers to a different (or unformatted) disk, and the non-`nofail` mount failed at boot.
*   **C)** The `dump` field should have been `1`.
*   **D)** `/etc/fstab` only supports one non-root entry.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Kernel names like `/dev/sdb1` are assigned in detection order and are not stable. Adding another disk can make `/dev/sdb1` point at the new, unformatted disk. The entry has no `nofail`, so when the mount fails, systemd treats it as a fatal boot problem and drops to the emergency shell. Using `UUID=` (or `LABEL=`/`PARTUUID=`) and adding `nofail` for a non-essential disk both prevent this.
*   **Why others are incorrect:**
    *   *Option A* is wrong — ext4 is the most common fstab filesystem type.
    *   *Option C* is wrong — `dump` is a legacy backup flag, almost always `0`, and does not affect booting.
    *   *Option D* is wrong — `/etc/fstab` has no practical limit on entries.
</details>

---

### Question 7
Which `/etc/fstab` field controls the order in which `fsck` checks filesystems at boot, and what value belongs on a non-root local data filesystem?
*   **A)** The 4th field (options); use `check=2`.
*   **B)** The 5th field (dump); use `2`.
*   **C)** The 6th field (pass); use `2`.
*   **D)** The 6th field (pass); use `1`.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** The sixth field is `pass` (fsck order). `0` means never check, `1` is reserved for the root filesystem (checked first, alone), and `2` is for other local filesystems (checked after root, in parallel with each other). A data disk gets `2`.
*   **Why others are incorrect:**
    *   *Option A* is wrong — there is no `check=` mount option; ordering is the sixth field.
    *   *Option B* is wrong — the fifth field is `dump`, unrelated to `fsck`.
    *   *Option D* is wrong — `1` is only for the root filesystem; giving two filesystems `1` would serialise and can cause problems.
</details>

---

### Question 8
You add an NFS export to `/etc/fstab`. Which option must be present so the system does not try to mount it before networking is available?
*   **A)** `noauto`
*   **B)** `_netdev`
*   **C)** `nofail`
*   **D)** `x-mount.mkdir`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `_netdev` marks the mount as network-dependent. systemd then orders it after `network-online.target` and does not attempt it during early boot. Without it, the mount is tried before the network is up, fails, and can stall the boot.
*   **Why others are incorrect:**
    *   *Option A* (`noauto`) means "do not mount automatically at all" — it would not mount on boot even when the network is ready.
    *   *Option C* (`nofail`) stops a missing mount from failing the boot, but does not fix the ordering; the mount would simply be skipped.
    *   *Option D* (`x-mount.mkdir`) just creates the mount-point directory if it is missing.
</details>

---

### Question 9
You want to mount an ext4 filesystem at `/srv/data` using a native systemd unit instead of `/etc/fstab`. What must the unit file be named?
*   **A)** `data.mount`
*   **B)** `srv-data.mount`
*   **C)** `srv/data.mount`
*   **D)** Any name, as long as `Where=/srv/data` is set.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** A `.mount` unit's filename must be the mount path with systemd path-escaping applied: the leading slash is dropped and remaining slashes become dashes, giving `srv-data.mount`. The `Where=` line inside must match (`/srv/data`). `systemd-escape -p --suffix=mount /srv/data` produces the correct name.
*   **Why others are incorrect:**
    *   *Option A* omits the `srv` path component; it would describe `/data`, not `/srv/data`.
    *   *Option C* is invalid — a filename cannot contain a slash.
    *   *Option D* is wrong — systemd ignores a `.mount` unit whose filename does not match its `Where=` path.
</details>

---

### Question 10
You want `/srv/data` to mount only when something first accesses it and to unmount after 30 seconds idle, without writing any unit files. What do you put in the `/etc/fstab` options field?
*   **A)** `defaults,noauto`
*   **B)** `defaults,x-systemd.automount,x-systemd.idle-timeout=30`
*   **C)** `defaults,comment=systemd.automount`
*   **D)** `defaults,autofs,timeout=30`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `x-systemd.automount` tells the fstab generator to create a paired `.automount` unit, so the filesystem mounts on first access; `x-systemd.idle-timeout=30` unmounts it after 30 seconds with no activity. A `systemctl daemon-reload` activates the change. No unit files needed.
*   **Why others are incorrect:**
    *   *Option A* (`noauto`) prevents automatic mounting entirely, with no on-access trigger.
    *   *Option C* uses an old comment-style syntax that current systemd does not honour for automount; `x-systemd.automount` is the supported form.
    *   *Option D* invents options — `autofs` and a bare `timeout=` are not valid ext4/fstab mount options for this purpose.
</details>
