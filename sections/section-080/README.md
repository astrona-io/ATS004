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

This section has four modules, each with an ungraded hands-on playground you run while you read:

### 1. Directory Capacity Auditing
*   **Module Reader:** **[Module 1: Directory Capacity Auditing](./module-01/course.md)**
*   **Hands-on Playground:** `sections/section-080/module-01/playground/` — a VM with a second mounted filesystem plus large and sparse seed files.
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-080/module-01/playground
    ```
*   **You will:** Rank subdirectories with `du -h -d 1 | sort -hr`, audit the root filesystem with `du -hx`, and compare `du` (allocated blocks) against `--apparent-size` on a sparse file.

### 2. User and Group Disk Quotas
*   **Module Reader:** **[Module 2: User and Group Disk Quotas](./module-02/course.md)**
*   **Hands-on Playground:** `sections/section-080/module-02/playground/` — an ext4 filesystem at `/quota` (quota options set, not yet enabled) with test users.
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-080/module-02/playground
    ```
*   **You will:** Turn quotas on with `quotacheck` and `quotaon`, give a user a 40M/50M limit with `setquota`, watch a write fail at the hard limit, and observe the grace-period countdown in `repquota`.

### 3. XFS Quotas and Project Quotas
*   **Module Reader:** **[Module 3: XFS Quotas and Project Quotas](./module-03/course.md)**
*   **Hands-on Playground:** `sections/section-080/module-03/playground/` — an XFS filesystem at `/srv/xfs` with `uquota,pquota` and a `webdata` directory.
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-080/module-03/playground
    ```
*   **You will:** Read the quota `state`, set a user limit with `xfs_quota -x`, define the `webdata` project in `/etc/projects` / `/etc/projid`, and cap the directory tree with a project quota that applies to every user.

### 4. Navigating Shortcuts: Symbolic Links & FHS
*   **Module Reader:** **[Module 4: Navigating Shortcuts: Symbolic Links & FHS](./module-04/course.md)**
*   **Hands-on Playground:** `sections/section-080/module-04/playground/` — real usrmerge symlinks plus a disposable demo with a reset helper.
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-080/module-04/playground
    ```
*   **You will:** Find top-level symlinks with `find -type l`, resolve them with `readlink -f` / `realpath` / `namei`, see why `du` reports a symlink as `0`, and remove a link safely while understanding the trailing-slash danger.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before moving on:

*   **[Take the Section 080 Knowledge Check Quiz](./quiz.md)**
