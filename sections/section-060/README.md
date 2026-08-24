# Section 060: Virtual Filesystems (/proc and /sys)

Welcome to Section 060. This section explores the fundamental Unix philosophy: "Everything is a file." You will look beyond traditional hard drives to understand how the Linux kernel exposes its internal state, running processes, and hardware configuration as a navigable directory tree.

## Section Objectives

By the end of this section, you will master the following competencies:
* Understand the architecture of pseudo-filesystems and 0-byte VFS callbacks.
* Diagnose memory leaks and open file handles by navigating process directories in `/proc`.
* Query raw kernel metrics, including live mount states and memory accounting.
* Tune running kernel parameters on the fly using `/sys`, `/proc/sys`, and `sysctl`.

## Modules

### [Module 1: The Process Blueprint: Inside /proc](./module-01/course.md)
* **Analogy:** The oil dipstick and fuel level gauges of a high-tech car.
* **Core Topics:** The "everything is a file" philosophy, dynamic 0-byte files, memory accounting via `/proc/meminfo`, and diagnosing file descriptor leaks by exploring `/proc/<PID>/fd/`.

### [Module 2: The Hardware Tree & Runtime Tuning: /sys & sysctl](./module-02/course.md)
* **Analogy:** Changing active engine control tuning through the dashboard dial.
* **Core Topics:** Navigating hardware and driver classes in `/sys`, auditing active mounts with `/proc/mounts`, and modifying active kernel behavior using `sysctl` and `/proc/sys/`.

## Lab Exercise

Apply your knowledge in a practical environment:
* **[Lab 060: Virtual Filesystems](../../labs/lab-060/README.md)**: Practice querying process state, diagnosing artificial file descriptor leaks, and tuning kernel network parameters using virtual filesystems.
