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

## The Learning & Lab Path

This section is divided into four highly focused, sequential modules. Each module is paired with a dedicated hands-on virtual sandbox practice lab, and concluded with a comprehensive Capstone Integration Challenge:

### 1. Filesystem Creation, Mounting, & Forensics
*   **Module Reader:** **[Module 1: Filesystem Creation, Mounting, & Forensics](./module-01/course.md)**
*   **Practice Lab Sandbox:** **`labs/lab-014`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-014
    ```
*   **Hands-on Objective:** Identify a newly attached raw disk, format it with ext4, mount it cleanly to `/mnt/backup-black`, and create a completed marker file.

### 2. Partitioning Raw Storage
*   **Module Reader:** **[Module 2: Partitioning Raw Storage](./module-02/course.md)**
*   **Practice Lab Sandbox:** **`labs/lab-011`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-011
    ```
*   **Hands-on Objective:** Design a modern GPT partition table on a raw block device and partition it safely with correct page alignment using `parted` or `fdisk`.

### 3. Securing Data-at-Rest
*   **Module Reader:** **[Module 3: Securing Data-at-Rest with LUKS](./module-03/course.md)**
*   **Practice Lab Sandbox:** **`labs/lab-012`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-012
    ```
*   **Hands-on Objective:** Encrypt a local storage partition with `cryptsetup luksFormat`, open the encrypted block map, format the mapped volume with ext4, mount it for secure writes, and lock it back down.

### 4. Filesystem Maintenance, Labeling, & Tuning
*   **Module Reader:** **[Module 4: Filesystem Maintenance, Labeling, & Tuning](./module-04/course.md)**
*   **Practice Lab Sandbox:** **`labs/lab-013`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-013
    ```
*   **Hands-on Objective:** Troubleshoot a corrupted filesystem. Run `fsck` offline to restore integrity, assign a volume label using `tune2fs -L`, and extract its UUID for a secure fstab mount.

### 5. Section Capstone Challenge
*   **Comprehensive Challenge:** **`labs/lab-010` (Local Storage Integration)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-010
    ```
*   **Hands-on Objective:** Connect the dots. Identify and format a new disk, mount it, audit capacity across active partitions, empty hidden trash directories, and identify and force-evict active background processes blockading disk operations.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the practical lab missions:

*   **[Take the Section 010 Knowledge Check Quiz](./quiz.md)**
