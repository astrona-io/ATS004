# iSCSI Disk on a Remote Server

QEMU lab for the LFCS course: log in to an iSCSI target, put a filesystem on the
disk it gives you, and mount it so it survives a reboot. Two VMs: `client` (where
you work) and `server` (the target).

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-020/module-03/labs/lab-01
```
