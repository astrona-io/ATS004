# Section 080: Capacity, Quotas & the Filesystem Hierarchy

Welcome to Section 080. This section is about knowing — and controlling — where disk space goes.

When a server alerts you that storage is critically full, you need to locate the consumption fast, without your query hanging in virtual directories or wandering onto a network share. Then you need to stop it happening again: **disk quotas** cap how much each user, group, or directory tree may consume on a filesystem. Finally, the same audits have to account for **symbolic links**, which the Filesystem Hierarchy Standard now uses heavily and which a naive tool mis-measures.

---

## What You Will Master

By completing this section, you will acquire four core capacity-management capabilities:
*   **Local Space Auditing:** How to recursively measure folder capacities (`du`) while forcing the tool to stay strictly on the local device (`-x`), skip pseudo-filesystems, and sort the results to expose the heavy directories.
*   **ext4 Quotas:** How to enable quotas with the right mount options plus `quotacheck` and `quotaon`, set soft/hard block and inode limits with `setquota`/`edquota`, explain the grace period, and read usage with `repquota`.
*   **XFS & Project Quotas:** How XFS enables quotas by mount option alone, how to set user limits with `xfs_quota`, and how to define a project in `/etc/projects` / `/etc/projid` and cap a directory tree regardless of file ownership.
*   **Symbolic Link Auditing:** How to identify (`find -type l`) and resolve (`readlink -f`, `realpath`) shortcut targets, why `du` treats a symlink as weightless, and the trailing-slash `rm` mistake that destroys a link's target.

---

## The Learning Path

This section has four modules, each with an ungraded hands-on playground you run while you read, and a graded practice lab:

### 1. Directory Capacity Auditing
*   **Module Reader:** **[Module 1: Directory Capacity Auditing](./module-01/course.md)**
    1. [df vs du, and Reading du at a Sensible Depth](./module-01/course-01-df-vs-du-depth-and-units.md)
    2. [Staying on One Filesystem & Allocated vs Apparent Size](./module-01/course-02-one-filesystem-and-apparent-size.md)
*   **Hands-on Playground:** `sections/section-080/module-01/playground/` — a VM with a second mounted filesystem plus large and sparse seed files.
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-080/module-01/playground
    ```
*   **Practice Lab Sandbox:** **`sections/section-080/module-01/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-080/module-01/labs/lab-01
    ```
*   **Hands-on Objective:** Rank subdirectories with `du -h -d 1 | sort -hr`, audit the root filesystem with `du -hx`, and compare `du` (allocated blocks) against `--apparent-size` on a sparse file.

### 2. User and Group Disk Quotas
*   **Module Reader:** **[Module 2: User and Group Disk Quotas](./module-02/course.md)**
    1. [Turning Quotas On & Setting Limits](./module-02/course-01-turning-on-and-setting-limits.md)
    2. [Hitting the Limit & the Grace Period](./module-02/course-02-hitting-the-limit-and-grace-period.md)
*   **Hands-on Playground:** `sections/section-080/module-02/playground/` — an ext4 filesystem at `/quota` (quota options set, not yet enabled) with test users.
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-080/module-02/playground
    ```
*   **Practice Lab Sandbox:** **`sections/section-080/module-02/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-080/module-02/labs/lab-01
    ```
*   **Hands-on Objective:** Turn quotas on with `quotacheck` and `quotaon`, set per-user and per-group block limits with `setquota`, and confirm them with `repquota`.
*   **Practice Lab Sandbox 2:** **`sections/section-080/module-02/labs/lab-02`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-080/module-02/labs/lab-02
    ```
*   **Hands-on Objective:** Actually hit a hard limit and watch the write get stopped, then cross a soft limit and confirm a real grace-period countdown starts.

### 3. XFS Quotas and Project Quotas
*   **Module Reader:** **[Module 3: XFS Quotas and Project Quotas](./module-03/course.md)**
    1. [XFS Quotas & User Limits](./module-03/course-01-xfs-quotas-and-user-limits.md)
    2. [Defining & Enforcing a Project Quota](./module-03/course-02-project-quotas.md)
*   **Hands-on Playground:** `sections/section-080/module-03/playground/` — an XFS filesystem at `/srv/xfs` with `uquota,pquota` and a `webdata` directory.
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-080/module-03/playground
    ```
*   **Practice Lab Sandbox:** **`sections/section-080/module-03/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-080/module-03/labs/lab-01
    ```
*   **Hands-on Objective:** Set a user limit with `xfs_quota -x`, define the `webdata` project in `/etc/projects` / `/etc/projid`, and cap the directory tree with a project quota that applies to every user regardless of ownership.

### 4. Navigating Shortcuts: Symbolic Links & FHS
*   **Module Reader:** **[Module 4: Navigating Shortcuts: Symbolic Links & FHS](./module-04/course.md)**
    1. [What a Symlink Is & Finding Them](./module-04/course-01-what-a-symlink-is-and-finding-them.md)
    2. [Resolving, du's Blind Spot & Removing Safely](./module-04/course-02-resolving-du-and-removing-safely.md)
*   **Hands-on Playground:** `sections/section-080/module-04/playground/` — real usrmerge symlinks plus a disposable demo with a reset helper.
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-080/module-04/playground
    ```
*   **Practice Lab Sandbox:** **`sections/section-080/module-04/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-080/module-04/labs/lab-01
    ```
*   **Hands-on Objective:** Find top-level symlinks with `find -type l`, resolve them with `readlink -f` / `realpath` / `namei`, see why `du` reports a symlink as `0`, and remove a link safely while understanding the trailing-slash danger.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before moving on:

*   **[Take the Section 080 Knowledge Check Quiz](./quiz.md)**
