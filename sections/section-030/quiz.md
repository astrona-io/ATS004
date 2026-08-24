# Section 030 Knowledge Check: LVM

Test your understanding of the LVM architecture layers, Physical Extent allocations, live pvmove data migrations, and volume reduction procedures.

---

## Scenario-Based Questions

### Question 1
You are constructing a high-availability database disk pool. You initialize `/dev/vdb` and `/dev/vdc` as LVM physical devices, aggregate them into a volume pool named `db_pool`, and create a logical volume named `user_data` inside it. What is the correct sequence of commands to execute this?
*   **A)** `pvcreate /dev/vdb /dev/vdc` $\rightarrow$ `vgcreate db_pool /dev/vdb /dev/vdc` $\rightarrow$ `lvcreate -L 20G -n user_data db_pool`
*   **B)** `lvcreate -n user_data db_pool` $\rightarrow$ `vgcreate db_pool /dev/vdb` $\rightarrow$ `pvcreate /dev/vdb`
*   **C)** `mkfs.ext4 /dev/vdb` $\rightarrow$ `pvcreate /dev/vdb` $\rightarrow$ `vgcreate user_data /dev/vdb`
*   **D)** `pvcreate db_pool` $\rightarrow$ `vgcreate user_data db_pool` $\rightarrow$ `lvcreate /dev/vdb`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: A**

*   **Why A is correct:** LVM requires a strict bottom-up building-block order. First, raw block devices must be initialized as Physical Volumes (`pvcreate`). Second, those PVs must be grouped together to create a Volume Group pool (`vgcreate`). Finally, you allocate a Logical Volume slice of a specific size (`-L`) and name (`-n`) out of that Volume Group pool (`lvcreate`).
*   **Why others are incorrect:**
    *   *Option B* is incorrect because you cannot create a Logical Volume before the parent Volume Group and underlying Physical Volumes are defined.
    *   *Option C* is incorrect because you must not format the raw physical device with a filesystem before initializing it with LVM; LVM handles its own internal extent boundaries.
    *   *Option D* is incorrect because it lists parameters in the wrong command scopes.
</details>

---

### Question 2
You need to remove a physical hard drive `/dev/vdb` from an active LVM Volume Group `vol1` to swap the hardware. The drive currently holds active, allocated physical extents used by running databases. What is the most critical first command you must run to prevent data loss?
*   **A)** `sudo vgreduce vol1 /dev/vdb`
*   **B)** `sudo pvmove /dev/vdb`
*   **C)** `sudo pvremove /dev/vdb`
*   **D)** `sudo lvreduce -L -10G /dev/vol1/data`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** If a physical disk contains active physical extents (allocated storage blocks), removing it from the Volume Group pool will instantly destroy the Logical Volumes crossing those blocks. You must run `pvmove /dev/vdb` first. This command tells LVM to dynamically copy all allocated blocks off `/dev/vdb` and write them onto any other physical disks within `vol1` that have available free space—completely online with zero application downtime.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because running `vgreduce` before moving the data will fail or immediately corrupt your filesystems.
    *   *Option C* is incorrect because `pvremove` is used to wipe LVM signatures from a disk completely, which can only be done *after* it is safely removed from the VG.
    *   *Option D* is incorrect because it shrinks a logical volume, but does not migrate the specific physical blocks off `/dev/vdb`.
</details>

---

### Question 3
What are **Physical Extents (PEs)** within LVM, and why do they matter when allocating space?
*   **A)** They are physical sectors on the SSD that cannot be resized.
*   **B)** They are the smallest dynamic block units (usually 4MB chunks) that LVM uses to allocate space to Volume Groups and Logical Volumes.
*   **C)** They are configuration lines stored inside `/etc/lvm/lvm.conf`.
*   **D)** They are virtual mounting points used to connect LVs to VFS.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** When LVM initializes Physical Volumes and groups them into a Volume Group, it divides the combined storage pool into small, identical, fixed-size chunks called Physical Extents (PEs), which default to 4 Megabytes. When you request a 40MB Logical Volume, LVM allocates exactly 10 of these extents. This modular chunk structure is what allows LVM to expand, shrink, and migrate storage sectors dynamically on the fly.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because sector boundaries are handled at the controller firmware level, whereas PEs are handled at the logical LVM software layer.
    *   *Option C* is incorrect because PEs are active data blocks on disk, not configuration file text strings.
    *   *Option D* is incorrect because mounting is a VFS operation, whereas extents operate down at the block storage allocation layer.
</details>

---

### Question 4
You have successfully expanded an active Logical Volume from 20GB to 30GB using `sudo lvextend -L 30G /dev/vol1/user_data`. However, when you run `df -h`, the mounted partition still displays its size as 20GB. What is the cause of this discrepancy?
*   **A)** You must reboot the server for the kernel to update its active disk layouts.
*   **B)** You extended the logical block boundary, but you have not yet expanded the filesystem database nested inside the volume.
*   **C)** The volume group `vol1` has run out of physical extents.
*   **D)** The `lvextend` command failed to write changes to disk.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct (Vesey's Law):** A Logical Volume behaves like a virtual hard drive, and inside that virtual hard drive sits your filesystem database (ext4 or XFS). Extending the virtual drive size (`lvextend`) merely increases the container capacity. To make the filesystem database aware of the new space, you must grow the filesystem itself. For ext4 filesystems, you must run `resize2fs /dev/vol1/user_data`, and for XFS filesystems, you must run `xfs_growfs /mnt/mountpoint`.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because Linux filesystem expansions can be performed entirely online with zero reboots or downtime.
    *   *Option C* is incorrect because if the VG was out of extents, `lvextend` would have aborted with an error during execution.
    *   *Option D* is incorrect because `lvextend` returns a success state once the LV container partition is expanded.
</details>

---

### Question 5
Which command should you run to get a quick, compact, 1-line-per-item summary of all active Volume Groups currently configured on your system?
*   **A)** `sudo vgdisplay`
*   **B)** `sudo vgs`
*   **C)** `cat /proc/lvm`
*   **D)** `sudo blkid`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** LVM provides compact, 1-line summary status tools for each layer: `pvs` for Physical Volumes, `vgs` for Volume Groups, and `lvs` for Logical Volumes. This is the cleanest way to check capacity and extent pools instantly.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `vgdisplay` outputs a highly verbose, multi-line detailed breakdown of every VG parameter, which is harder to read at a glance.
    *   *Option C* is incorrect because `/proc` does not contain an active LVM text device file.
    *   *Option D* is incorrect because `blkid` shows raw filesystem UUIDs and types, but cannot parse or detail LVM volume group allocations.
</details>
