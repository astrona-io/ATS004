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

## The Learning Path

This section is organized into a single comprehensive guide:

*   **[Module 1: Swap Space Management](./module-01)**
    Explore virtual memory, the swappiness kernel parameter, and security configurations. Learn how to create secured swap file safety valves, set up swap partitions, and write priority entries in your fstab maps.

---

## Hands-On Practice Mission

Once you have read through the narrative guide, you are ready to secure a server suffering from OOM memory crashes:

*   **[Go to Lab 040](../../labs/lab-040)**: Build a tiered virtual memory system using a highly-secured swap file and a prioritized swap partition.
