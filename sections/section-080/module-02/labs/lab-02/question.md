# Question

Solve this question on: `terminal`

An ext4 filesystem is mounted at `/quota2` with user and group quotas
already enabled. A user `carol` already has a tight block quota of 20M
soft / 25M hard.

1.  As `carol`, attempt to write a 30M file into `/quota2/carol/`. Confirm
    the write is cut off at her hard limit — her usage in that directory
    must not exceed 25M on disk.
2.  Set a 2-minute block grace period on the filesystem
    (`setquota -t 120 120 /quota2`). As `carol`, write enough to go over
    her 20M soft limit but stay under her 25M hard limit. While she is in
    that state, save `repquota -s /quota2` output to
    `/root/grace-evidence.txt` so it shows carol marked over her soft
    limit with a live grace countdown.
