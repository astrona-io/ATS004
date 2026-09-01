# Section 040: Swap Space Management

Welcome to Section 040. In this section, we study how Linux handles memory exhaustion crises.

Every operating system must handle the moment where applications request more physical RAM than the computer possesses. Left unmanaged, the Linux kernel is forced to invoke the Out-of-Memory (OOM) Killer, terminating random databases or web server processes to prevent a system crash.

To protect your system from these sudden shutdowns, you must configure **Swap Space**. Swap space acts as a safety valve, allowing the kernel to temporarily offload inactive application memory blocks onto secondary storage, keeping the system stable under heavy workloads.

---

## What You Will Master

By completing this section, you will acquire three core virtual memory management capabilities:
*   **Swap File Creation:** How to dynamically allocate, secure (`chmod 600`), format, and activate swap files to handle memory spikes on the fly.
*   **Swap Partition Allocation:** How to format and mount dedicated swap partitions for optimized, raw virtual memory blocks.
*   **Priority Tuning:** How to configure `/etc/fstab` to prioritize fast swap partitions over slow swap file fallbacks, ensuring optimal kernel performance.

---

## The Learning & Lab Path

This section is divided into two modules, both paired with hands-on practice inside the memory allocation laboratory environment:

### 1. Temporary Safety Valves: Swap Files
*   **Module Reader:** **[Module 1: Temporary Safety Valves: Swap Files](./module-01/course.md)**
*   **Associated Lab:** **`labs/section-040/capstone/lab-01` (Part I)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-040/capstone/lab-01
    ```
*   **Hands-on Objective:** Identify a server running out of memory. Allocate a 2G swap file on the local root partition, secure its permissions, initialize it, and enable it.

### 2. Permanent Swap Partitions & Priority Scheduling
*   **Module Reader:** **[Module 2: Permanent Swap Partitions & Priority Scheduling](./module-02/course.md)**
*   **Associated Lab:** **`labs/section-040/capstone/lab-01` (Part II)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-040/capstone/lab-01
    ```
*   **Hands-on Objective:** Identify an unformatted raw disk partition on a secondary drive. Settle and format it as a swap partition, make both swap zones persistent inside `/etc/fstab`, and configure priorities so the fast partition (`pri=10`) is preferred over the slow file (`pri=5`).

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the swap lab mission:

*   **[Take the Section 040 Knowledge Check Quiz](./quiz.md)**
