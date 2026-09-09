# Section 010: Local Storage Preparation & Forensics

Welcome to your first major domain in Linux storage administration. In this section, we move from treating storage as an abstract folder on your screen to managing the physical and logical block layers directly on raw disk metal.

As an administrator, you are responsible for the entire lifecycle of a local disk. When your organization purchases new storage arrays or provisions virtual disks, they arrive as blank, unformatted block devices. Your mission is to take those raw resources and transform them into secure, resilient, and highly organized storage directories ready to hold production database files and user profiles.

---

## What You Will Master

By completing this section, you will acquire six core administrative capabilities:
*   **Disk Discovery & Analysis:** How to query the kernel to identify newly attached, unformatted physical drives and trace filesystem signatures without risking data loss.
*   **Partition Design:** How to structure disks using standard MBR and modern GPT partition tables to balance compatibility, redundancy, and performance.
*   **Data-at-Rest Security:** How to encrypt storage sectors using enterprise LUKS encryption to protect sensitive data from offline cloning or hardware theft.
*   **Filesystem Maintenance & Forensics:** How to check filesystem integrity, repair metadata corruptions, and locate and safely evict rogue processes blockading standard disk operations.
*   **Persistent Mounting:** How to write correct `/etc/fstab` entries — stable identifiers, safe options (`nofail`, `_netdev`, `noatime`), correct `dump`/`pass` — and verify them with `mount -a` and `findmnt --verify` before a reboot can act on them.
*   **systemd Mount Management:** How every mount is a systemd unit, how to write a native `.mount` unit and pair it with an `.automount`, and how `x-systemd.*` fstab options achieve the same with no unit files.

---

## The Learning & Lab Path

This section is divided into six sequential modules. Modules 1–4 are each paired with a dedicated graded sandbox lab; modules 5–6 come with an ungraded hands-on playground you run while you read. The section concludes with a comprehensive Capstone Integration Challenge:

### 1. Filesystem Creation, Mounting, & Forensics
*   **Module Reader:** **[Module 1: Filesystem Creation, Mounting, & Forensics](./module-01/course.md)**
    1. [Discovery, Formatting & Mounting](./module-01/course-01-discovery-formatting-mounting.md)
    2. [Diagnosing a Stuck Disk](./module-01/course-02-diagnosing-a-stuck-disk.md)
*   **Practice Lab Sandbox:** **`sections/section-010/module-01/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-010/module-01/labs/lab-01
    ```
*   **Hands-on Objective:** Identify a newly attached raw disk, format it with ext4, mount it cleanly to `/mnt/backup-black`, and create a completed marker file.

### 2. Partitioning Raw Storage
*   **Module Reader:** **[Module 2: Partitioning Raw Storage](./module-02/course.md)**
    1. [Partition Tables: MBR vs GPT](./module-02/course-01-partition-tables-mbr-vs-gpt.md)
    2. [Tools, Alignment & the Kernel Re-read Problem](./module-02/course-02-tools-alignment-and-kernel-rescan.md)
*   **Practice Lab Sandbox:** **`sections/section-010/module-02/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-010/module-02/labs/lab-01
    ```
*   **Hands-on Objective:** Design a modern GPT partition table on a raw block device and partition it safely with correct page alignment using `parted` or `fdisk`.

### 3. Securing Data-at-Rest
*   **Module Reader:** **[Module 3: Securing Data-at-Rest with LUKS](./module-03/course.md)**
    1. [The LUKS Model: Locking a Disk](./module-03/course-01-the-luks-model.md)
    2. [Creating a Container & Its Keyslots](./module-03/course-02-creating-a-container-and-keyslots.md)
    3. [Opening, Using, Closing & What's Visible Outside](./module-03/course-03-opening-using-closing.md)
*   **Practice Lab Sandbox:** **`sections/section-010/module-03/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-010/module-03/labs/lab-01
    ```
*   **Hands-on Objective:** Encrypt a local storage partition with `cryptsetup luksFormat`, open the encrypted block map, format the mapped volume with ext4, mount it for secure writes, and lock it back down.

### 4. Filesystem Maintenance, Labeling, & Tuning
*   **Module Reader:** **[Module 4: Filesystem Maintenance, Labeling, & Tuning](./module-04/course.md)**
    1. [Filesystem Corruption & the fsck Repair Model](./module-04/course-01-fsck-repair-model.md)
    2. [Labels, UUIDs & Tuning Check Intervals](./module-04/course-02-labels-uuids-and-tuning.md)
*   **Practice Lab Sandbox:** **`sections/section-010/module-04/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-010/module-04/labs/lab-01
    ```
*   **Hands-on Objective:** Troubleshoot a corrupted filesystem. Run `fsck` offline to restore integrity, assign a volume label using `tune2fs -L`, and extract its UUID for a secure fstab mount.

### 5. /etc/fstab in Depth
*   **Module Reader:** **[Module 5: /etc/fstab in Depth](./module-05/course.md)**
    1. [fstab Fields & Stable Identifiers](./module-05/course-01-fields-and-stable-identifiers.md)
    2. [Options & Verifying Before You Trust It](./module-05/course-02-options-and-verifying.md)
*   **Hands-on Playground:** `sections/section-010/module-05/playground/`
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-010/module-05/playground
    ```
*   **Practice Lab Sandbox:** **`sections/section-010/module-05/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-010/module-05/labs/lab-01
    ```
*   **Hands-on Objective:** Format a raw disk, mount it, and add a persistent `/etc/fstab` entry keyed by `UUID=` with `nofail`/`noatime` and correct `dump`/`pass` fields — verified safe with `findmnt --verify` before it could break a boot.

### 6. systemd Mount and Automount Units
*   **Module Reader:** **[Module 6: systemd Mount and Automount Units](./module-06/course.md)**
    1. [How /etc/fstab Becomes systemd Units](./module-06/course-01-fstab-generated-units-and-naming.md)
    2. [Writing Native .mount and .automount Units](./module-06/course-02-native-mount-and-automount-units.md)
    3. [The fstab Shortcut and Common Pitfalls](./module-06/course-03-fstab-shortcut-and-pitfalls.md)
*   **Hands-on Playground:** `sections/section-010/module-06/playground/`
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-010/module-06/playground
    ```
*   **Practice Lab Sandbox:** **`sections/section-010/module-06/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-010/module-06/labs/lab-01
    ```
*   **Hands-on Objective:** Write a native `.mount` unit and pair it with an `.automount` unit with an idle timeout, enable the automount (not the mount), and confirm first-access triggers it.

### 7. Section Capstone Challenge
*   **Comprehensive Challenge:** **`sections/section-010/capstone/labs/lab-01` (Local Storage Integration)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-010/capstone/labs/lab-01
    ```
*   **Hands-on Objective:** Connect the dots. Identify and format a new disk, mount it, audit capacity across active partitions, empty hidden trash directories, and identify and force-evict active background processes blockading disk operations.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the practical lab missions:

*   **[Take the Section 010 Knowledge Check Quiz](./quiz.md)**
