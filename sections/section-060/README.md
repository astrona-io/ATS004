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
*   **Associated Lab:** **`labs/section-060/capstone/lab-01` (Part I)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-060/capstone/lab-01
    ```
*   **Hands-on Objective:** Extract live memory metrics (such as total and available RAM) from the kernel memory log, and count the active file descriptors of a targeted PID inside `/proc/<PID>/fd/`.

### 2. The Hardware Tree & Runtime Tuning: `/sys` & `sysctl`
*   **Module Reader:** **[Module 2: The Hardware Tree & Runtime Tuning: /sys & sysctl](./module-02/course.md)**
*   **Associated Lab:** **`labs/section-060/capstone/lab-01` (Part II)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-060/capstone/lab-01
    ```
*   **Hands-on Objective:** Temporarily enable IPv4 packet routing directly inside the virtual kernel write-intercepts under `/proc/sys/`, query the parameter using `sysctl`, and audit active mount structures directly from the live kernel mount ledger `/proc/mounts`.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the kernel systems lab mission:

*   **[Take the Section 060 Knowledge Check Quiz](./quiz.md)**
