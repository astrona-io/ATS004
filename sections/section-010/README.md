# Section 010: Local Storage Preparation & Forensics

Welcome to your first major domain in Linux storage administration. In this section, we move from treating storage as an abstract folder on your screen to managing the physical and logical block layers directly on raw disk metal.

As an administrator, you are responsible for the entire lifecycle of a local disk. When your organization purchases new storage arrays or provisions virtual disks, they arrive as blank, unformatted block devices. Your mission is to take those raw resources and transform them into secure, resilient, and highly organized storage directories ready to hold production database files and user profiles.

---

## What You Will Master

By completing this section, you will acquire four core administrative capabilities:
*   **Disk Discovery & Analysis:** How to query the kernel to identify newly attached, unformatted physical drives and trace filesystem signatures without risking data loss.
*   **Partition Design:** How to structure disks using standard MBR and modern GPT partition tables to balance compatibility, redundancy, and performance.
*   **Data-at-Rest Security:** How to encrypt storage sectors using enterprise LUKS encryption to protect sensitive data from offline cloning or hardware theft.
*   **Filesystem Maintenance & Forensics:** How to check filesystem integrity, repair metadata corruptions, and locate and safely evict rogue processes blockading standard disk operations.

---

## The Learning Path

This section is divided into four highly focused, sequential modules:

*   **[Module 1: Filesystem Creation, Mounting, & Forensics](./module-01)**
    Learn how to format raw storage with the journaling `ext4` filesystem, mount it securely into the VFS directory tree, and hunt down processes lockading active devices.
*   **[Module 2: Partitioning Raw Storage](./module-02)**
    Master partition tables. Compare legacy MBR with modern GUID Partition Tables (GPT), align sectors to prevent SSD performance wear, and partition drives using `fdisk` and `parted`.
*   **[Module 3: Securing Data-at-Rest with LUKS](./module-03)**
    Secure your block storage. Walk through mapping, formatting, mounting, and locking high-security cryptographic LUKS volumes using `cryptsetup`.
*   **[Module 4: Filesystem Maintenance, Labeling, & Tuning](./module-04)**
    Audit and manage existing filesystems. Master offline volume repair (`fsck`), metadata tuning (`tune2fs`), volume labeling, and stable UUID mount maps.

---

## Hands-On Practice Mission

Once you have read through the narrative guides in each module, you are ready to test your skills in a live, simulated production environment:

*   **[Go to Lab 010](../../labs/lab-010)**: Put your filesystem preparation, active process auditing, and directory cleaning skills to the test.
