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

## The Learning & Lab Path

This section is divided into two modules, both paired with hands-on practice in the kernel virtual filesystem laboratory environment:

### 1. The Process Blueprint: Inside `/proc`
*   **Module Reader:** **[Module 1: The Process Blueprint: Inside /proc](./module-01/course.md)**
    1. [/proc as a Live View & System-wide Files](./module-01/course-01-live-view-and-system-wide-files.md)
    2. [Per-Process Directories & Open File Descriptors](./module-01/course-02-per-process-and-file-descriptors.md)
*   **Practice Lab Sandbox:** **`sections/section-060/module-01/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-060/module-01/labs/lab-01
    ```
*   **Hands-on Objective:** Extract live memory metrics (such as total and available RAM) from the kernel memory log, and count the active file descriptors of a targeted PID inside `/proc/<PID>/fd/`.

### 2. The Hardware Tree & Runtime Tuning: `/sys` & `sysctl`
*   **Module Reader:** **[Module 2: The Hardware Tree & Runtime Tuning: /sys & sysctl](./module-02/course.md)**
    1. [The Hardware Tree & the Mount List](./module-02/course-01-hardware-tree-and-mount-list.md)
    2. [sysctl: Viewing, Changing & Persisting](./module-02/course-02-sysctl-viewing-changing-persisting.md)
*   **Practice Lab Sandbox:** **`sections/section-060/module-02/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-060/module-02/labs/lab-01
    ```
*   **Hands-on Objective:** Temporarily enable IPv4 packet routing directly inside the virtual kernel write-intercepts under `/proc/sys/`, query the parameter using `sysctl`, and audit active mount structures directly from the live kernel mount ledger `/proc/mounts`.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the kernel systems lab mission:

*   **[Take the Section 060 Knowledge Check Quiz](./quiz.md)**
