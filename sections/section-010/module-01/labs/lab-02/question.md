# Question

Solve this question on: `terminal`

A disk is already formatted and mounted at `/mnt/locked-vault`. A background
process is actively using it, which is stopping it from being unmounted.

1.  Attempt to unmount `/mnt/locked-vault` and confirm the kernel refuses
    because the target is busy.
2.  Use `lsof` and/or `fuser` to identify exactly which process is holding
    the mount open.
3.  Stop that process cleanly — try a graceful termination first, and only
    force it if it does not exit on its own. Do not stop any other running
    service or process on the system.
4.  Unmount `/mnt/locked-vault` successfully once the process is gone.
