# Section 060: Virtual Filesystems (/proc and /sys)

Welcome to Section 060. In this section, we explore the core design philosophy of Linux: "Everything is a file."

In Linux, you do not need proprietary binaries or complex APIs to query how many processes are running, what hardware is active, or how much memory is free. The Linux kernel exposes its live, active internal data structures directly to you as a plain-text directory tree inside `/proc` and `/sys`.

By learning how to navigate these virtual filesystems, you gain the ability to inspect the kernel, audit application file handles, and adjust active system tuning on the fly—all by reading and writing to files.

---

## What You Will Master

By completing this section, you will acquire three core kernel auditing capabilities:
*   **Live Kernel Memory Auditing:** How to extract accurate, real-time memory facts directly from `/proc/meminfo`.
*   **Process Resource Auditing:** How to investigate running processes and count active open file descriptors inside `/proc/<PID>/fd/`.
*   **Runtime Kernel Tuning:** How to temporarily view and modify live kernel variables (like IP packet forwarding) on the fly using `sysctl` and `/proc/sys/`.

---

## The Learning Path

This section is organized into a single comprehensive guide:

*   **[Module 1: Virtual Filesystems: /proc and /sys](./module-01)**
    Explore the mechanics of 0-byte dynamic VFS filesystem callbacks. Learn how to debug file descriptor leaks, inspect memory pools, and tune kernel parameters on a live boot.

---

## Hands-On Practice Mission

Once you have read through the narrative guide, you are ready to conduct live kernel-state diagnostics:

*   **[Go to Lab 060](../../labs/lab-060)**: Extract live memory metrics, audit a process's open file descriptors, and temporarily adjust system network packet routing.
