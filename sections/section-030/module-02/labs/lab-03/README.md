# section-030 / module-02: Growing a Live Pool with vgextend, Then Evacuating a Disk

QEMU VM for the LFCS course — add a second disk to an already-live, nearly-full Volume Group with `vgextend`, then use that new capacity to migrate every extent off the original disk with `pvmove` and retire it with `vgreduce` + `pvremove`.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-030/module-02/labs/lab-03
```
