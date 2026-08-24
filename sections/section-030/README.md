# Section 030: Dynamic Volume Management (LVM)

Welcome to Section 030. This section transitions from physical, rigid storage concepts into abstract, fluid volume management. You will learn how the Logical Volume Manager (LVM) decouples filesystems from physical hardware, granting the flexibility to adapt storage infrastructure without downtime.

## Section Objectives

By the end of this section, you will master the following competencies:
* Understand the architecture of LVM: Physical Volumes, Volume Groups, and Logical Volumes.
* Provision dynamic storage pools across multiple physical disks.
* Execute high-stakes live maintenance tasks, including migrating active data off failing hardware.
* Safely resize block devices and their underlying filesystems while the system remains fully operational.

## Modules

### [Module 1: LVM Fundamentals](./module-01/course.md)
* **Analogy:** Laying out cubicle terrain in an open warehouse.
* **Core Topics:** Limitations of static partitions, the LVM stack components (`pvcreate`, `vgcreate`, `lvcreate`), command groups (`pvs`, `vgs`, `lvs`), and understanding Physical Extents (PEs) as the standard currency of LVM.

### [Module 2: Advanced LVM Operations](./module-02/course.md)
* **Analogy:** Dynamically sliding cubicle walls during live active operations.
* **Core Topics:** Zero-downtime maintenance. Evacuating extents from disks using `pvmove`, safely shrinking volume groups (`vgreduce`), extending logical boundaries (`lvextend`), and commanding the filesystem to grow into new space (`resize2fs`, `xfs_growfs`).

## Lab Exercise

Apply your knowledge in a practical environment:
* **[Lab 030: Dynamic Volume Management (LVM)](../../labs/lab-030/README.md)**: Practice building LVM structures, expanding logical volumes, and performing live disk replacements.
