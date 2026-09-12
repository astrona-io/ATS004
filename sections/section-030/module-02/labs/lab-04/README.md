# section-030 / module-02: Removing One PV Out of Three, With Mixed Extents

QEMU VM for the LFCS course — a Volume Group spans three disks and one Logical Volume's extents are already spread across all of them; migrate one specific disk's share off with `pvmove` and retire it with `vgreduce` + `pvremove`, without disturbing the other two.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-030/module-02/labs/lab-04
```
