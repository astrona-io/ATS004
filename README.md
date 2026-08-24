# ATS004 - LFCS: Storage Training Series

[![Liberapay](https://img.shields.io/badge/Liberapay-Support_Astrona.io-F6C915?logo=liberapay&logoColor=black&style=for-the-badge)](https://liberapay.com/Astrona.io)

Welcome to **ATS004**, a comprehensive, free training curriculum designed to help you fully master and pass the **Storage** domain of the **Linux Foundation Certified System Administrator (LFCS)** exam. 

Storage represents **20% of the total LFCS exam weight**. This repository bridges theoretical operating system design with real-world, command-line muscle memory, transforming you from a Linux beginner into a confident systems administrator.

---

## The Symmetrical 1:1:1 Learning Framework

To make learning intuitive, digestible, and robust, this curriculum is built around a symmetrical **1:1:1 educational architecture**:

1.  **The Textbook Lesson (`sections/section-XXX/module-YY/course.md`):** Narrative, book-style chapters written in a warm, expert "teacher's voice" that explain *why* the operating system functions the way it does using real-world metaphors, inline command option breakdowns, and clear diagrams.
2.  **The Interactive Quiz (`sections/section-XXX/quiz.md`):** A scenario-based theoretical knowledge check testing diagnostic reasoning, complete with collapsible answers and technical explanation keys.
3.  **The Dedicated Laboratory (`labs/lab-XXX/`):** A virtual machine sandbox environment launched instantly via the `astrona` CLI where you must solve practical storage objectives and validate your system states using automated testing scripts.

---

## Complete Curriculum & Lab Mapping

The training series is divided into **8 main sections** containing **18 highly focused modules**, **18 targeted lab sandboxes**, and **8 comprehensive Section Capstone Challenges**:

| Section & Domain | Module & Chapter Reader | Practice Lab Sandbox | astrona CLI Run Command |
| :--- | :--- | :--- | :--- |
| **010: Local Storage** | [M1: Filesystem & Forensics](sections/section-010/module-01/course.md) | [lab-014](labs/lab-014) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-014` |
| | [M2: Raw Partitioning](sections/section-010/module-02/course.md) | [lab-011](labs/lab-011) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-011` |
| | [M3: LUKS Encryption](sections/section-010/module-03/course.md) | [lab-012](labs/lab-012) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-012` |
| | [M4: Integrity & Labeling](sections/section-010/module-04/course.md) | [lab-013](labs/lab-013) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-013` |
| | **Section Capstone Challenge** | **[lab-010](labs/lab-010)** | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-010` |
| **020: Remote Filesystems** | [M1: SSHFS Mounting](sections/section-020/module-01/course.md) | [lab-021](labs/lab-021) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-021` |
| | [M2: Enterprise NFS sharing](sections/section-020/module-02/course.md) | [lab-022](labs/lab-022) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-022` |
| | **Section Capstone Challenge** | **[lab-020](labs/lab-020)** | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-020` |
| **030: Dynamic Volumes** | [M1: LVM Fundamentals](sections/section-030/module-01/course.md) | [lab-031](labs/lab-031) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-031` |
| | [M2: Advanced LVM](sections/section-030/module-02/course.md) | [lab-032](labs/lab-032) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-032` |
| | **Section Capstone Challenge** | **[lab-030](labs/lab-030)** | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-030` |
| **040: Swap Space** | [M1: Swap Files Safety](sections/section-040/module-01/course.md) | [lab-041](labs/lab-041) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-041` |
| | [M2: Swap Partitions & Priorities](sections/section-040/module-02/course.md) | [lab-042](labs/lab-042) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-042` |
| | **Section Capstone Challenge** | **[lab-040](labs/lab-040)** | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-040` |
| **050: On-Demand Mounting**| [M1: autofs Direct Maps](sections/section-050/module-01/course.md) | [lab-051](labs/lab-051) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-051` |
| | [M2: Network automount Maps](sections/section-050/module-02/course.md) | [lab-052](labs/lab-052) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-052` |
| | **Section Capstone Challenge** | **[lab-050](labs/lab-050)** | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-050` |
| **060: Virtual Filesystems**| [M1: Inside `/proc` processes](sections/section-060/module-01/course.md) | [lab-061](labs/lab-061) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-061` |
| | [M2: `/sys` & `sysctl` Tuning](sections/section-060/module-02/course.md) | [lab-062](labs/lab-062) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-062` |
| | **Section Capstone Challenge** | **[lab-060](labs/lab-060)** | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-060` |
| **070: Performance Audit** | [M1: Device Latency iostat](sections/section-070/module-01/course.md) | [lab-071](labs/lab-071) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-071` |
| | [M2: Process audits iotop/lsof](sections/section-070/module-02/course.md) | [lab-072](labs/lab-072) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-072` |
| | **Section Capstone Challenge** | **[lab-070](labs/lab-070)** | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-070` |
| **080: Capacity & Symlinks**| [M1: du Capacity Audits](sections/section-080/module-01/course.md) | [lab-081](labs/lab-081) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-081` |
| | [M2: Symlinks & FHS Standard](sections/section-080/module-02/course.md) | [lab-082](labs/lab-082) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-082` |
| | **Section Capstone Challenge** | **[lab-080](labs/lab-080)** | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-080` |

---

## How to Navigate This Course

To get the most value out of this curriculum, follow this step-by-step roadmap:

1.  **Enter a Domain Portal:** Navigate into a domain directory, such as `sections/section-010/`, and open its `README.md` to review the section's core philosophy and administrative master competencies.
2.  **Read the Chapters:** Open and read the narrative chapters in order (e.g., `module-01/course.md` and then `module-02/course.md`). Focus on the metaphors, diagrams, and inline command breakdowns.
3.  **Take the Chapter Self-Check:** Challenge yourself with the conceptual questions at the bottom of the course modules.
4.  **Test Your Diagnostics:** Open `quiz.md` inside that section and answer its 5 scenario questions. Expand the HTML details tags to read the deep-dive teacher's explanations.
5.  **Practice the Sandboxes:** Run the targeted module sandboxes (e.g., `lab-011`, `lab-012`, etc.) to build muscle memory on atomic configurations.
6.  **Conquer the Capstone Challenges:** Ready for high-stakes practice? Boot up the section's comprehensive **Capstone Challenge Lab** (e.g., `lab-010`, `lab-020`, etc.), solve the integration prompts, and run the automated test validation suites to confirm your passing state.
7.  **Simulate the Exam:** Once you have completed all 18 modules, open **`sections/final-domain-quiz.md`** and complete the final 20-question, closed-book domain exam simulator under a 30-minute time cap to audit your readiness.

---

## Pure-Linux Administrative Focus

This curriculum is designed with strict educational boundaries. To align perfectly with the off-grid, host-level environment of the practical LFCS exam, **all modules and labs focus exclusively on standard host-level Linux system administration.** There are no Kubernetes, container, or cloud-native concepts introduced, allowing you to master core operating system concepts with zero external noise.

---

## Support This Project

ATS004 is free LFCS training material. If it helped you on your administrative journey, consider supporting ongoing work and resource development via [Liberapay](https://liberapay.com/Astrona.io).
