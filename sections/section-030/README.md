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

All four modules are paired with a graded sandbox lab; modules 3–4 (RAID) also come with an ungraded hands-on playground you can run while you read:

### 1. LVM Fundamentals
*   **Module Reader:** **[Module 1: LVM Fundamentals](./module-01/course.md)**
    1. [Why LVM & the Three-Layer Model](./module-01/course-01-why-lvm-and-the-stack.md)
    2. [Physical Volumes & Volume Groups](./module-01/course-02-pv-and-vg.md)
    3. [Logical Volumes](./module-01/course-03-logical-volumes.md)
*   **Practice Lab Sandbox:** **`sections/section-030/module-01/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-030/module-01/labs/lab-01
    ```
*   **Hands-on Objective:** Identify raw devices, initialize Physical Volumes (PV), aggregate them into a Volume Group (VG), and carve out formatted, ready-to-mount ext4 Logical Volumes (LV).

### 2. Advanced LVM Operations
*   **Module Reader:** **[Module 2: Advanced LVM Operations](./module-02/course.md)**
    1. [The LVM Stack, Recapped & Reading State](./module-02/course-01-stack-and-state.md)
    2. [Live Migration: pvmove](./module-02/course-02-pvmove-migration.md)
    3. [vgreduce, and Growing/Shrinking a Volume](./module-02/course-03-vgreduce-lvextend.md)
    4. [Removing Any PV, and Physical Disk Safety](./module-02/course-04-removing-any-pv-and-safety.md)
*   **Practice Lab Sandbox:** **`sections/section-030/module-02/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-030/module-02/labs/lab-01
    ```
*   **Hands-on Objective:** Shrink Volume Group `vol1` by running `pvmove` to migrate all allocated active extents off a physical disk without downtime, remove the freed disk via `vgreduce`, construct a new Volume Group `vol2` from it, and provision a new 50M logical volume named `p1` formatted with ext4.
*   **Practice Lab Sandbox (2):** **`sections/section-030/module-02/labs/lab-02`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-030/module-02/labs/lab-02
    ```
*   **Hands-on Objective:** Grow a mounted logical volume live with `lvextend` + `resize2fs`, then safely shrink it back down in the one order that doesn't destroy data — unmount, `e2fsck -f`, `resize2fs`, `lvreduce`.

### 3. Software RAID Fundamentals
*   **Module Reader:** **[Module 3: Software RAID Fundamentals](./module-03/course.md)**
    1. [RAID Levels](./module-03/course-01-raid-levels.md)
    2. [Creating & Persisting an Array](./module-03/course-02-creating-and-persisting.md)
*   **Hands-on Playground:** `sections/section-030/module-03/playground/` — a VM with four raw spare disks.
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-030/module-03/playground
    ```
*   **Practice Lab Sandbox:** **`sections/section-030/module-03/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-030/module-03/labs/lab-01
    ```
*   **Hands-on Objective:** Build a RAID 5 array from three raw disks with `mdadm --create`, put an ext4 filesystem on `/dev/md0`, mount it, and make it survive a reboot via `/etc/mdadm/mdadm.conf`, an initramfs refresh, and a UUID-keyed `/etc/fstab` entry.

### 4. RAID Maintenance and Recovery
*   **Module Reader:** **[Module 4: RAID Maintenance and Recovery](./module-04/course.md)**
    1. [Reading Health and Handling a Failure](./module-04/course-01-health-and-failure.md)
    2. [Growing an Array and Getting Notified](./module-04/course-02-growth-and-monitoring.md)
*   **Hands-on Playground:** `sections/section-030/module-04/playground/` — a VM with a pre-built RAID 5 and a raw spare disk.
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-030/module-04/playground
    ```
*   **Practice Lab Sandbox:** **`sections/section-030/module-04/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-030/module-04/labs/lab-01
    ```
*   **Hands-on Objective:** Given a healthy RAID 5 array, fail and remove a member disk, add the spare as its replacement, wait for the rebuild to finish, and confirm the array is back to a clean state with the data intact.
*   **Practice Lab Sandbox (2):** **`sections/section-030/module-04/labs/lab-02`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-030/module-04/labs/lab-02
    ```
*   **Hands-on Objective:** Grow a healthy RAID 5 array onto a fourth disk with `mdadm --grow`, extend the filesystem into the new space, and configure + test `mdadm --monitor` failure notification.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the lab missions:

*   **[Take the Section 030 Knowledge Check Quiz](./quiz.md)**
