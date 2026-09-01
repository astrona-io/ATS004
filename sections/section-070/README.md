# Section 070: Storage Performance Monitoring

Welcome to Section 070. In this section, we shift our focus from setting up storage to diagnosing it.

Slow disk performance is one of the most common and frustrating bottlenecks in production. When database operations lag or background scripts crawl, the CPU is often completely idle—simply sitting in a frozen state waiting for slow disks to write or read data blocks (I/O Wait).

To solve these performance crises, you must know how to monitor disk queue latency, track live process throughput, and trace disk activity directly to the offending applications.

---

## What You Will Master

By completing this section, you will acquire three core performance troubleshooting capabilities:
*   **Disk Saturation Analysis:** How to analyze device queue wait times and read/write latency using extended device metrics (`iostat -xz 1`).
*   **Real-Time I/O Tracking:** How to run live, process-level diagnostics to find which application thread is generating write load (`iotop -o`).
*   **Target File Auditing:** How to trace an active process's PID down to the exact files and paths it is locking on disk (`lsof`).

---

## The Learning & Lab Path

This section is divided into two modules, both paired with hands-on practice in the storage performance auditing laboratory environment:

### 1. Device-Level Diagnostics: Queues & Latency
*   **Module Reader:** **[Module 1: Device-Level Diagnostics: Queues & Latency](./module-01/course.md)**
*   **Associated Lab:** **`labs/section-070/capstone` (Part I)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-070/capstone
    ```
*   **Hands-on Objective:** Troubleshoot system lag. Run `iostat` on a live stressing VM, analyze average wait times (`await`), and identify which raw device is saturated.

### 2. Process-Level Auditing: Identifying the Culprit
*   **Module Reader:** **[Module 2: Process-Level Auditing: Identifying the Culprit](./module-02/course.md)**
*   **Associated Lab:** **`labs/section-070/capstone` (Part II)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-070/capstone
    ```
*   **Hands-on Objective:** Trace the disk load to a specific process PID using `iotop -o`, identify the exact files it is accessing on the disk using `lsof`, and correlate the device back to its user-facing mount point. Write your audited performance findings into `/opt/course/audit/io-report.txt`.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the performance lab mission:

*   **[Take the Section 070 Knowledge Check Quiz](./quiz.md)**
