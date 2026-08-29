# Section 030 Knowledge Check: Dynamic & Redundant Volumes

Test your understanding of the LVM architecture layers, Physical Extent allocations, live pvmove data migrations, volume reduction procedures, RAID levels and their trade-offs, and failure recovery with `mdadm`.

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

---

## Software RAID with mdadm (Modules 3–4)

### Question 6
A team lead asks for "RAID so we don't lose data if a disk dies" on a 4-disk server and wants maximum usable capacity. Which single level best fits, and why not RAID 0?
*   **A)** RAID 0 — it stripes across all four disks for full capacity and speed.
*   **B)** RAID 5 — usable capacity of three disks, survives any one disk failure.
*   **C)** RAID 1 — mirrors everything, the safest option.
*   **D)** RAID 10 — the only level that tolerates a failure.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** RAID 5 across four disks gives the usable capacity of three (one disk's worth of parity, distributed) and survives any single disk failure — the best capacity/redundancy balance for this request. RAID 0 must be rejected outright: it has **no** redundancy, and losing any one disk loses everything, so it is the opposite of what was asked.
*   **Why others are incorrect:**
    *   *Option A* — RAID 0 provides zero fault tolerance.
    *   *Option C* — RAID 1 (or a 4-disk RAID 10) works but only gives 50% usable capacity, not "maximum".
    *   *Option D* — RAID 10 also tolerates a failure, but at 50% capacity, and the claim that it is the *only* such level is false (1 and 5 also tolerate one failure).
</details>

---

### Question 7
After `mdadm --create /dev/md0 ...` and putting a filesystem on it, you reboot. The array comes back as `/dev/md127` and your `/etc/fstab` entry for `/dev/md0` fails. What step was skipped?
*   **A)** The array needed `mkfs` run on each member disk first.
*   **B)** The array UUID/name was never recorded in `/etc/mdadm/mdadm.conf` (and the initramfs not refreshed), so it was assembled with an auto-assigned name.
*   **C)** RAID arrays always come back as `md127`; the fstab entry must use that.
*   **D)** `mdadm --create` must be re-run at every boot.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Without an `ARRAY` line in `/etc/mdadm/mdadm.conf` (from `mdadm --detail --scan`) and an initramfs rebuild (`update-initramfs -u` / `dracut -f`), the boot process assembles the array by scanning superblocks and gives it a generic name like `/dev/md127`. Recording it pins the name back to `/dev/md0`.
*   **Why others are incorrect:**
    *   *Option A* — you format `/dev/md0`, never the members.
    *   *Option C* — `md127` is the *fallback* name, not a rule; a recorded array keeps its configured name.
    *   *Option D* — `--create` builds an array once; boot-time assembly is automatic when configured.
</details>

---

### Question 8
On a healthy 3-disk RAID 5, `/proc/mdstat` currently shows `[3/3] [UUU]`. You run `mdadm --manage /dev/md0 --fail /dev/vdc`. What happens to the array and the data on it immediately after?
*   **A)** The array stops and the filesystem becomes unreadable until the disk is replaced.
*   **B)** The array becomes degraded (`[3/2] [U_U]`) but keeps serving data, reconstructing the missing blocks from parity.
*   **C)** Nothing changes until the next reboot.
*   **D)** All three disks are wiped and the array must be recreated.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** RAID 5 tolerates one missing device. Failing `/dev/vdc` drops the array to a degraded state (`[U_U]`); reads and writes continue, with the kernel computing the missing stripe portions from the remaining data and parity. Redundancy is now gone, so replacement is urgent — a second failure would lose the array.
*   **Why others are incorrect:**
    *   *Option A* — a single failure does not stop a RAID 5.
    *   *Option C* — the state change is immediate, not deferred.
    *   *Option D* — `--fail` marks one member faulty; it does not touch the others' data.
</details>

---

### Question 9
You replaced a failed disk with `mdadm --manage /dev/md0 --add /dev/vde`. Which command shows the rebuild progress?
*   **A)** `df -h /dev/md0`
*   **B)** `cat /proc/mdstat`
*   **C)** `blkid /dev/md0`
*   **D)** `lsblk -f`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `/proc/mdstat` shows a live `recovery = NN%` progress bar with an ETA while `md` rebuilds the replacement disk from the surviving members. `mdadm --detail /dev/md0` shows the same as a `Rebuild Status` line.
*   **Why others are incorrect:**
    *   *Option A* — `df` reports filesystem usage, not array rebuild state.
    *   *Option C* — `blkid` reports the filesystem UUID/type, nothing about the rebuild.
    *   *Option D* — `lsblk -f` lists devices and filesystems but not rebuild progress.
</details>

---

### Question 10
You want to expand a 3-disk RAID 5 to 4 disks. After `mdadm --grow /dev/md0 --raid-devices=4` completes its reshape, the filesystem still reports the old size. What must you do, and what is the key precaution before starting a reshape?
*   **A)** Nothing else; reboot and the filesystem resizes itself. No precaution needed.
*   **B)** Run `resize2fs /dev/md0` (or `xfs_growfs`); and back up the data first, since an interrupted reshape can be unrecoverable.
*   **C)** Re-run `mkfs.ext4 /dev/md0` to pick up the new size.
*   **D)** Remove and re-add every disk one at a time.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** `mdadm --grow` enlarges the block device; the filesystem on top is unchanged until you extend it with `resize2fs` (ext4) or `xfs_growfs` (XFS). A reshape rewrites the entire stripe layout and must not be interrupted — back up first, and for parity levels use `--backup-file=` on a separate device so an interrupted reshape can resume.
*   **Why others are incorrect:**
    *   *Option A* — filesystems never auto-resize; a reshape is a high-risk operation, not a no-op.
    *   *Option C* — `mkfs` would destroy all existing data.
    *   *Option D* — that is not how capacity is added; `--grow` handles the redistribution.
</details>
