# Section 070: Storage Performance Monitoring

Welcome to Section 070. This section shifts focus from configuring storage to analyzing its real-time performance. You will learn how to identify I/O bottlenecks, measure hardware saturation, and trace those bottlenecks back to the exact application causing the problem.

## Section Objectives

By the end of this section, you will master the following competencies:
* Understand the difference between IOPS and throughput, and how they impact different workloads.
* Measure block device saturation, queue depths, and average wait times using `iostat`.
* Identify the specific processes consuming storage bandwidth using `iotop`.
* Correlate active file handles to offending processes using `lsof`.

## Modules

### [Module 1: Device-Level Diagnostics: Queues & Latency](./module-01/course.md)
* **Analogy:** The lightning-fast chef blocked by the slow dishwasher.
* **Core Topics:** Disk I/O wait queues, measuring hardware saturation (`%util`), analyzing sector performance and latency (`await` via `iostat -xz 1`), and the difference between high-IOPS and high-throughput workloads.

### [Module 2: Process-Level Auditing: Identifying the Culprit](./module-02/course.md)
* **Analogy:** Tracing active waiters in the restaurant to their dirty tables.
* **Core Topics:** Tracking live real-time process write throughput (`iotop -o`), querying active open file handles of suspicious PIDs (`lsof`), and linking bottlenecked physical blocks back to user-facing mount points.

## Lab Exercise

Apply your knowledge in a practical environment:
* **[Lab 070: Storage Performance Monitoring](../../labs/lab-070/README.md)**: Practice generating artificial disk loads, measuring device saturation, and isolating the specific background process consuming the I/O capacity.
