# Question

Solve this question on: `terminal`

A pre-built RAID5 array `/dev/md0` (three member disks) is mounted at `/mnt/raid` with production data on it. A fourth raw disk is standing by as a spare. The kernel names for all four are recorded in `/etc/lab034-raid` as `member1`, `member2`, `member3`, and `spare` — source that file rather than guessing device letters.

1. Source `/etc/lab034-raid` to get the device variables.
2. Simulate a disk failure: mark `$member2` as failed, then remove it from the array.
3. Add `$spare` to the array as its replacement.
4. Wait for the rebuild to finish.
5. Confirm the array is back to a healthy `clean` state with all three slots active, and that `/mnt/raid/data.txt` still has its original content.
