# ATS004 - LFCS: Storage

[![Liberapay](https://img.shields.io/badge/Liberapay-Support_Astrona.io-F6C915?logo=liberapay&logoColor=black&style=for-the-badge)](https://liberapay.com/Astrona.io)

Welcome to **ATS004**, a comprehensive, free training curriculum designed to help you fully master and pass the **Storage** domain of the **Linux Foundation Certified System Administrator (LFCS)** exam. 

Storage represents **20% of the total LFCS exam weight**. This repository bridges theoretical operating system design with real-world, command-line muscle memory, transforming you from a Linux beginner into a confident systems administrator.

---

## The Symmetrical 1:1:1 Learning Framework

To make learning intuitive, digestible, and robust, this curriculum is built around a symmetrical **1:1:1 educational architecture**:

1.  **The Textbook Lesson (`sections/section-XXX/module-YY/course.md`):** Narrative, book-style chapters written in a warm, expert "teacher's voice" that explain *why* the operating system functions the way it does using real-world metaphors, inline command option breakdowns, and clear diagrams.
2.  **The Interactive Quiz (`sections/section-XXX/quiz.md`):** A scenario-based theoretical knowledge check testing diagnostic reasoning, complete with collapsible answers and technical explanation keys.
3.  **The Dedicated Laboratory (`labs/section-XXX/module-YY/`, plus a `labs/section-XXX/capstone/` per section):** A virtual machine sandbox environment launched instantly via the `astrona` CLI where you must solve practical storage objectives and validate your system states using automated testing scripts.

A handful of newer modules ship with an **ungraded hands-on playground** (`sections/section-XXX/module-YY/playground/`) instead of a graded lab — a clean throwaway machine you run *while reading* the chapter, with no task and no scoring. Launch these with `astrona run ... -c sections/section-XXX/module-YY/playground`.

---

## Complete Curriculum & Lab Mapping

The training series is divided into **8 main sections** containing **24 focused modules**, **18 graded lab sandboxes**, **6 ungraded hands-on playgrounds**, and **8 comprehensive Section Capstone Challenges**:

| Section & Domain | Module & Chapter Reader | Practice Lab / Playground | astrona CLI Run Command |
| :--- | :--- | :--- | :--- |
| **010: Local Storage** | [M1: Filesystem & Forensics](sections/section-010/module-01/course.md) | [lab](labs/section-010/module-01/lab-01) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-010/module-01/lab-01` |
| | [M2: Raw Partitioning](sections/section-010/module-02/course.md) | [lab](labs/section-010/module-02/lab-01) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-010/module-02/lab-01` |
| | [M3: LUKS Encryption](sections/section-010/module-03/course.md) | [lab](labs/section-010/module-03/lab-01) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-010/module-03/lab-01` |
| | [M4: Integrity & Labeling](sections/section-010/module-04/course.md) | [lab](labs/section-010/module-04/lab-01) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-010/module-04/lab-01` |
| | [M5: /etc/fstab in Depth](sections/section-010/module-05/course.md) | playground | `astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-010/module-05/playground` |
| | [M6: systemd Mount & Automount Units](sections/section-010/module-06/course.md) | playground | `astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-010/module-06/playground` |
| | **Section Capstone Challenge** | **[capstone](labs/section-010/capstone/lab-01)** | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-010/capstone/lab-01` |
| **020: Remote Filesystems** | [M1: SSHFS Mounting](sections/section-020/module-01/course.md) | [lab](labs/section-020/module-01/lab-01) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-020/module-01/lab-01` |
| | [M2: Enterprise NFS sharing](sections/section-020/module-02/course.md) | [lab](labs/section-020/module-02/lab-01) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-020/module-02/lab-01` |
| | **Section Capstone Challenge** | **[capstone](labs/section-020/capstone/lab-01)** | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-020/capstone/lab-01` |
| **030: Dynamic & Redundant Volumes** | [M1: LVM Fundamentals](sections/section-030/module-01/course.md) | [lab](labs/section-030/module-01/lab-01) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-030/module-01/lab-01` |
| | [M2: Advanced LVM](sections/section-030/module-02/course.md) | [lab](labs/section-030/module-02/lab-01) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-030/module-02/lab-01` |
| | [M3: Software RAID Fundamentals](sections/section-030/module-03/course.md) | playground | `astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-030/module-03/playground` |
| | [M4: RAID Maintenance & Recovery](sections/section-030/module-04/course.md) | playground | `astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-030/module-04/playground` |
| | **Section Capstone Challenge** | **[capstone](labs/section-030/capstone/lab-01)** | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-030/capstone/lab-01` |
| **040: Swap Space** | [M1: Swap Files Safety](sections/section-040/module-01/course.md) | [lab](labs/section-040/module-01/lab-01) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-040/module-01/lab-01` |
| | [M2: Swap Partitions & Priorities](sections/section-040/module-02/course.md) | [lab](labs/section-040/module-02/lab-01) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-040/module-02/lab-01` |
| | **Section Capstone Challenge** | **[capstone](labs/section-040/capstone/lab-01)** | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-040/capstone/lab-01` |
| **050: On-Demand Mounting**| [M1: autofs Direct Maps](sections/section-050/module-01/course.md) | [lab](labs/section-050/module-01/lab-01) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-050/module-01/lab-01` |
| | [M2: Network automount Maps](sections/section-050/module-02/course.md) | [lab](labs/section-050/module-02/lab-01) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-050/module-02/lab-01` |
| | **Section Capstone Challenge** | **[capstone](labs/section-050/capstone/lab-01)** | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-050/capstone/lab-01` |
| **060: Virtual Filesystems**| [M1: Inside `/proc` processes](sections/section-060/module-01/course.md) | [lab](labs/section-060/module-01/lab-01) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-060/module-01/lab-01` |
| | [M2: `/sys` & `sysctl` Tuning](sections/section-060/module-02/course.md) | [lab](labs/section-060/module-02/lab-01) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-060/module-02/lab-01` |
| | **Section Capstone Challenge** | **[capstone](labs/section-060/capstone/lab-01)** | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-060/capstone/lab-01` |
| **070: Performance Audit** | [M1: Device Latency iostat](sections/section-070/module-01/course.md) | [lab](labs/section-070/module-01/lab-01) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-070/module-01/lab-01` |
| | [M2: Process audits iotop/lsof](sections/section-070/module-02/course.md) | [lab](labs/section-070/module-02/lab-01) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-070/module-02/lab-01` |
| | **Section Capstone Challenge** | **[capstone](labs/section-070/capstone/lab-01)** | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-070/capstone/lab-01` |
| **080: Capacity, Quotas & Symlinks**| [M1: du Capacity Audits](sections/section-080/module-01/course.md) | [lab](labs/section-080/module-01/lab-01) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-080/module-01/lab-01` |
| | [M2: User & Group Quotas](sections/section-080/module-02/course.md) | playground | `astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-080/module-02/playground` |
| | [M3: XFS & Project Quotas](sections/section-080/module-03/course.md) | playground | `astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-080/module-03/playground` |
| | [M4: Symlinks & FHS Standard](sections/section-080/module-04/course.md) | [lab](labs/section-080/module-04/lab-01) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-080/module-04/lab-01` |
| | **Section Capstone Challenge** | **[capstone](labs/section-080/capstone/lab-01)** | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/section-080/capstone/lab-01` |

---

## How to Navigate This Course

To get the most value out of this curriculum, follow this step-by-step roadmap:

1.  **Enter a Domain Portal:** Navigate into a domain directory, such as `sections/section-010/`, and open its `README.md` to review the section's core philosophy and administrative master competencies.
2.  **Read the Chapters:** Open and read the narrative chapters in order (`module-01/course.md`, `module-02/course.md`, …). Focus on the metaphors, diagrams, and inline command breakdowns. Where a chapter has a linked playground, run it and work the "Try it" checkpoints as you read.
3.  **Take the Chapter Self-Check:** Challenge yourself with the conceptual questions at the bottom of the course modules.
4.  **Test Your Diagnostics:** Open `quiz.md` inside that section and answer its scenario questions (5–10 per section). Expand the HTML details tags to read the deep-dive teacher's explanations.
5.  **Practice the Sandboxes:** Run the targeted module labs (e.g., `labs/section-010/module-02/lab-01`, `labs/section-010/module-03/lab-01`, …) to build muscle memory on atomic configurations.
6.  **Conquer the Capstone Challenges:** Ready for high-stakes practice? Boot up the section's comprehensive **Capstone Challenge Lab** (e.g., `labs/section-010/capstone/lab-01`, `labs/section-020/capstone/lab-01`, etc.), solve the integration prompts, and run the automated test validation suites to confirm your passing state.
7.  **Simulate the Exam:** Once you have completed all 24 modules, open **`sections/final-domain-quiz.md`** and complete the final closed-book domain exam simulator under a 30-minute time cap to audit your readiness.

---

## Pure-Linux Administrative Focus

This curriculum is designed with strict educational boundaries. To align perfectly with the off-grid, host-level environment of the practical LFCS exam, **all modules and labs focus exclusively on standard host-level Linux system administration.** There are no Kubernetes, container, or cloud-native concepts introduced, allowing you to master core operating system concepts with zero external noise.

---

## Support This Project

ATS004 is free LFCS training material. If it helped you on your administrative journey, consider supporting ongoing work and resource development via [Liberapay](https://liberapay.com/Astrona.io).
