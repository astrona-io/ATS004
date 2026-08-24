# Section 030: Dynamic Volume Management (LVM)

Welcome to Section 030. In this section, we solve one of the greatest challenges of traditional system administration: static partition boundaries.

If you allocate 50GB to a traditional partition, and that partition fills up, you are facing a labor-intensive and risky migration to expand it—even if you have 100GB of empty space sitting unused on a neighboring drive. 

To solve this, Linux employs **LVM (Logical Volume Manager)**. LVM abstracts raw hardware, allowing you to pool physical disks together and slice out flexible, dynamic "logical volumes" that can be expanded or shrunk instantly—even while applications are actively reading and writing to them.

---

## What You Will Master

By completing this section, you will acquire three core dynamic storage capabilities:
*   **LVM Architecture Design:** How to structure and manage Physical Volumes (PVs), Volume Groups (VGs), and Logical Volumes (LVs).
*   **Live Data Migration:** How to migrate active storage extents from one physical disk to another on the fly with zero downtime using `pvmove`.
*   **Volume Pool Reduction:** How to safely shrink Volume Groups and remove physical hardware from active storage pools.

---

## The Learning & Lab Path

This section is divided into two modules, both paired with hands-on practice inside the LVM configuration laboratory environment:

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

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the LVM lab mission:

*   **[Take the Section 030 Knowledge Check Quiz](./quiz.md)**
