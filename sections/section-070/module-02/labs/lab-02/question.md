# Question

Solve this question on: `terminal`

Astronaut, the spool hold at `/mnt/spool` (disk `/dev/disk/by-id/virtio-lab070202-spool`) is filling up, but `ls` shows only one small file. Something is holding space without a name. You also have to pin the I/O scheduler of that disk.

1. Compare `df -h /mnt/spool` with `du -sh /mnt/spool`. The two do not agree.
2. Use `sudo lsof +L1 /mnt/spool` to find the process that holds a **deleted** file open. Write the process ID (PID) of that process into `/root/holder-pid.txt`.
3. Free the space by stopping that process. Confirm with `df -h /mnt/spool` and `sudo lsof +L1 /mnt/spool`.
4. Make the scheduler of the spool disk `mq-deadline`, and make that survive a restart: write a udev rule in `/etc/udev/rules.d/` (a file name ending in `.rules`) that sets `queue/scheduler` to `mq-deadline` for that disk. Find the disk's kernel name with `lsblk`.
5. Reload the rules and trigger them, then check `cat /sys/block/<disk>/queue/scheduler`: `mq-deadline` is shown in square brackets.

The grader compares the PID in `/root/holder-pid.txt` with the real holder, checks that the process is gone and the space is back, and reads the rule file and the live scheduler setting.
