# Section 040: Swap Space Management

Welcome to Section 040. This section covers the critical safety net of Linux memory management: swap space. You will learn how the kernel handles memory exhaustion, how to provision emergency overflow storage, and how to tune the priority of these storage spaces to keep servers responsive under extreme load.

## Section Objectives

By the end of this section, you will master the following competencies:
* Understand the kernel's Out-Of-Memory (OOM) killer logic and the role of swap.
* Provision, secure, and activate temporary swap files on existing filesystems.
* Configure dedicated swap partitions for permanent, high-speed memory overflow.
* Tune swap priority queues to guarantee the kernel exhausts fast physical partitions before falling back to slower swap files.

## Modules

### [Module 1: Temporary Safety Valves: Swap Files](./module-01/course.md)
* **Analogy:** Pulling folders from your active work desk to a cabinet drawer to avoid the paper shredder.
* **Core Topics:** Virtual memory limits, OOM-killer mechanics, allocating space (`fallocate` vs `dd`), securing swap permissions (`chmod 600`), formatting (`mkswap`), and temporary activation (`swapon`/`swapoff`).

### [Module 2: Permanent Swap Partitions & Priority Scheduling](./module-02/course.md)
* **Analogy:** Dedicated, high-speed automated storage bins in a factory.
* **Core Topics:** Initializing raw dedicated partitions, persisting swap configurations in `/etc/fstab`, and tuning scheduling priority (`pri=`) to optimize performance across multiple swap devices.

## Lab Exercise

Apply your knowledge in a practical environment:
* **[Lab 040: Swap Space Management](../../labs/lab-040/README.md)**: Practice creating both swap files and partitions, managing permissions, setting up persistent fstab entries, and verifying priority queues under load.
