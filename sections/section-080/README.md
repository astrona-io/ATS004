# Section 080: Filesystem Hierarchy and Directory Sizing

Welcome to Section 080. In this section, we master filesystem capacity auditing and navigation.

When a server alerts you that disk storage is critically full, you need to quickly locate where the space is being consumed. However, naive filesystem queries can lead to massive administrative errors: they can hang in virtual directories, double-count separate external drives, or get lost in endless shortcut paths.

To generate accurate capacity reports, you must understand how to isolate your disk queries to a single physical device, skip memory-only virtual streams, and audit symbolic links across the root filesystem directory tree.

---

## What You Will Master

By completing this section, you will acquire three core capacity auditing capabilities:
*   **Local Space Auditing:** How to recursively measure folder capacities (`du`) while forcing the tool to stay strictly on the local device (`-x`) and avoiding virtual folders.
*   **Data Aggregation & Sorting:** How to filter and sort storage outputs numerically in descending order (`sort -hr`) to immediately expose heavy directories.
*   **Symbolic Link Auditing:** How to identify, locate (`find -type l`), and resolve shortcut pointer targets across the root directory tree.

---

## The Learning & Lab Path

This section is divided into two modules, both paired with hands-on practice in the filesystem capacity reporting laboratory environment:

### 1. Directory Capacity Auditing
*   **Module Reader:** **[Module 1: Directory Capacity Auditing](./module-01/course.md)**
*   **Associated Lab:** **`labs/lab-080` (Part I)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-080
    ```
*   **Hands-on Objective:** Audit system capacity on the local filesystem. Run `du` recursively, restrict depth output to `1`, force the tool to skip separate filesystems (`-x`) and pseudo-filesystems, sort the results numerically, and output findings into `/opt/course/audit/dirsizes.txt`.

### 2. Navigating Shortcuts: Symbolic Links & FHS
*   **Module Reader:** **[Module 2: Navigating Shortcuts: Symbolic Links & FHS](./module-02/course.md)**
*   **Associated Lab:** **`labs/lab-080` (Part II)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-080
    ```
*   **Hands-on Objective:** Audit all top-level symbolic links under `/`. Isolate them using `find`, resolve their actual absolute target paths using `readlink`, and document your shortcut audit inside `/opt/course/audit/symlinks.txt`.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the capacity lab mission:

*   **[Take the Section 080 Knowledge Check Quiz](./quiz.md)**
