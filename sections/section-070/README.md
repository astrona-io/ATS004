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

## The Learning Path

This section is organized into a single comprehensive guide:

*   **[Module 1: Storage Performance Monitoring](./module-01)**
    Explore disk queues, %util, wait latency (`await`), and the differences between high-IOPS and high-throughput workloads. Master performance diagnostics, locate bottlenecked drives, and evict heavy daemons.

---

## Hands-On Practice Mission

Once you have read through the narrative guide, you are ready to troubleshoot a live storage bottleneck:

*   **[Go to Lab 070](../../labs/lab-070)**: Diagnose a slow data server, identify the saturated raw device, isolate the process generating the I/O load, and document your findings.
