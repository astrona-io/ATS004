# Question

Solve this question on: `terminal`

A pre-built RAID5 array `/dev/md0` (three member disks) is mounted at
`/mnt/raid-grow` with production data on it. A fourth raw disk is standing
by. The kernel names for all four are recorded in `/etc/lab036-raid` as
`member1`, `member2`, `member3`, and `spare` — source that file rather
than guessing device letters.

1.  Source `/etc/lab036-raid`.
2.  Add `$spare` to the array and grow it to use all four disks
    (`mdadm --grow --raid-devices=4`).
3.  Wait for the reshape to finish.
4.  Grow the ext4 filesystem on `/dev/md0` so it can use the array's new
    capacity.
5.  Confirm `/mnt/raid-grow/data.txt` still has its original content.
6.  Set up failure notification: add a `MAILADDR` line to
    `/etc/mdadm/mdadm.conf` and confirm a test alert fires with
    `mdadm --monitor`.
