# Section 030: Dynamic & Redundant Volumes (LVM & RAID)

Welcome to Section 030. This section is about combining raw disks into a single managed block device — one that is more flexible, or fault-tolerant, or both — instead of being stuck with static partition boundaries on one physical drive.

Two kernel subsystems do this. **LVM (Logical Volume Manager)** pools disks into a space you slice into logical volumes that grow, shrink, and migrate between disks while mounted. **Software RAID (`md` / `mdadm`)** combines disks into an array that survives a disk failure and rebuilds onto a replacement without downtime. Both present the result as an ordinary block device you format and mount.

---

## What You Will Master

By completing this section, you will acquire five core volume-management capabilities:
*   **LVM Architecture Design:** How to structure and manage Physical Volumes (PVs), Volume Groups (VGs), and Logical Volumes (LVs).
*   **Live Data Migration:** How to migrate active storage extents from one physical disk to another on the fly with zero downtime using `pvmove`, and how to grow a volume and its filesystem live.
*   **Volume Pool Reduction:** How to safely shrink Volume Groups and remove physical hardware from active storage pools.
*   **RAID Array Design:** How RAID 0, 1, 5, and 10 trade capacity against redundancy; how to build an array with `mdadm --create`, put a filesystem on it, and make it reassemble at boot.
*   **RAID Failure Recovery:** How to mark a member failed, replace it and watch the rebuild, grow an array onto more disks, and configure failure notification with `mdadm --monitor`.

---

## The Learning & Lab Path

Modules 1–2 (LVM) are each paired with a graded sandbox lab; modules 3–4 (RAID) come with an ungraded hands-on playground you run while you read:

### 1. LVM Fundamentals
*   **Module Reader:** **[Module 1: LVM Fundamentals](./module-01/course.md)**
*   **Associated Lab:** **`labs/lab-030` (Part I)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-030
    ```
*   **Hands-on Objective:** Identify raw devices, initialize Physical Volumes (PV), aggregate them into a Volume Group (VG), and carve out formatted, ready-to-mount ext4 Logical Volumes (LV).

### 2. Advanced LVM Operations
*   **Module Reader:** **[Module 2: Advanced LVM Operations](./module-02/course.md)**
*   **Associated Lab:** **`labs/lab-030` (Part II)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-030
    ```
*   **Hands-on Objective:** Shrink Volume Group `vol1` by running `pvmove` to migrate all allocated active extents off a physical disk without downtime, remove the freed disk via `vgreduce`, construct a new Volume Group `vol2` from it, and provision a new 50M logical volume named `p1` formatted with ext4.

### 3. Software RAID Fundamentals
*   **Module Reader:** **[Module 3: Software RAID Fundamentals](./module-03/course.md)**
*   **Hands-on Playground:** `sections/section-030/module-03/playground/` — a VM with four raw spare disks.
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-030/module-03/playground
    ```
*   **You will:** Compare RAID levels, build a mirror with `mdadm --create`, watch the resync in `/proc/mdstat`, put an ext4 filesystem on `/dev/md0`, and record the array in `/etc/mdadm/mdadm.conf`.

### 4. RAID Maintenance and Recovery
*   **Module Reader:** **[Module 4: RAID Maintenance and Recovery](./module-04/course.md)**
*   **Hands-on Playground:** `sections/section-030/module-04/playground/` — a VM with a pre-built RAID 5 and a raw spare disk.
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-030/module-04/playground
    ```
*   **You will:** Degrade the array with `--fail`, remove and `--add` a replacement, watch the rebuild, grow the array with `mdadm --grow` and `resize2fs`, and send a test alert with `mdadm --monitor`.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the lab missions:

*   **[Take the Section 030 Knowledge Check Quiz](./quiz.md)**
