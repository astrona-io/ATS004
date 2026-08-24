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

## The Learning Path

This section is organized into a single comprehensive guide:

*   **[Module 1: Filesystem Hierarchy and Directory Sizing](./module-01)**
    Explore the FHS filesystem standard. Learn how to measure directories cleanly without crossing mount boundaries, exclude pseudo-filesystems, sort capacities numerically, and audit symlinks.

---

## Hands-On Practice Mission

Once you have read through the narrative guide, you are ready to conduct a storage capacity audit on a production VM:

*   **[Go to Lab 080](../../labs/lab-080)**: Generate a sorted capacity report of top-level directories on the root filesystem, exclude virtual streams and mounted drives, and audit all root-level symlinks.
