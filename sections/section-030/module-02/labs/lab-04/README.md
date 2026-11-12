# Removing One PV Out of Three, With Mixed Extents

**Optional practice.** Advanced variation: evacuate a middle PV across existing disks without adding capacity. The main learning path uses [lab 038](../lab-03/README.md). This ID remains runnable and covered by CI.

QEMU VM for the LFCS course — a Volume Group spans three disks and one Logical Volume's extents are already spread across all of them; migrate one specific disk's share off with `pvmove` and retire it with `vgreduce` + `pvremove`, without disturbing the other two.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-030/module-02/labs/lab-04
```
