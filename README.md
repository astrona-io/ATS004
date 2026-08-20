# ATS004 - LFCS: Storage

[![Liberapay](https://img.shields.io/badge/Liberapay-Support_Astrona.io-F6C915?logo=liberapay&logoColor=black&style=for-the-badge)](https://liberapay.com/Astrona.io)

Free LFCS (Linux Foundation Certified System Administrator) training material,
covering the **Storage** domain (20% of exam weight).

Each module maps to one exam competency and ships with:

- `sections/section-XXX/course.md` — reading material
- `labs/lab-XXX/` — hands-on lab
- `labs/lab-XXX/docs/question.md` + `solution.md` — practice question and walkthrough

## Lab Reference List

| Lab | Title | VMs | Run |
|-----|-------|:---:|-----|
| [lab-010](labs/lab-010) | Filesystem Creation, Mounting, and Disk/Process Forensics | 1 | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-010` |
| [lab-020](labs/lab-020) | Remote Filesystems: SSHFS and NFS | 2 (`terminal` + `app-srv1`) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-020` |
| [lab-030](labs/lab-030) | LVM Volume Groups and Logical Volumes | 1 | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-030` |
| [lab-040](labs/lab-040) | Swap Space Management | 1 | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-040` |
| [lab-050](labs/lab-050) | Filesystem Automount with autofs | 2 (`app-srv1` + `data-001`) | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-050` |
| [lab-060](labs/lab-060) | Virtual Filesystems: /proc and /sys | 1 | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-060` |
| [lab-070](labs/lab-070) | Storage Performance Monitoring | 1 | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-070` |
| [lab-080](labs/lab-080) | Filesystem Hierarchy and Directory Sizing | 1 | `astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-080` |

## Support This Project

ATS004 is free LFCS training material. If it helped you, consider supporting
ongoing work via [Liberapay](https://liberapay.com/Astrona.io).
