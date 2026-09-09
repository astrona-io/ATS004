# Part 2 — Growing an Array and Getting Notified

> Prerequisite: [Part 1 — Reading Health and Handling a Failure](./course-01-health-and-failure.md). Next: [Section 030 Knowledge Check](../quiz.md).

A healthy, rebuilt array (Part 1) is still fixed-size. This part covers adding capacity to a live array with `mdadm --grow`, why the filesystem on top does not notice until you tell it to, and setting up `mdadm --monitor` so a future failure does not sit silent until a second disk goes.

## Growing an array

`mdadm --grow` reshapes a live array. The common case is adding capacity: put another disk in and raise the device count. RAID 5 with 3 disks (2 usable) becomes 4 disks (3 usable).

Under the hood, RAID 5's stripe geometry is not just "more disks" — every stripe's data-plus-parity layout has to be recalculated across the *new* member count, and every existing stripe on disk has to be read, recomputed, and rewritten into the new layout. That rewrite touches the entire array, not just new space, which is why it is slow and why it must not be interrupted partway: an interrupted reshape can leave some stripes in the old layout and some in the new, with no record of where the boundary was. `--backup-file=<path>` (on a *separate* device, never a member of the array) checkpoints the in-progress region so an interrupted reshape can resume from where it left off instead of losing track. Back up your data first regardless — this is not a substitute for a backup, only for resumability.

## The block device and the filesystem grow separately

After `--grow` finishes, `/dev/md0` **is** bigger — `lsblk` and `blockdev --getsize64` see it immediately. But the ext4 (or XFS) filesystem sitting on top has its own size recorded in its own superblock, written when it was created, and it has no way of noticing the block device underneath it changed shape. Growing the device and growing the filesystem are two separate operations against two separate pieces of metadata, and only you connect them.

This is exactly the same two-step relationship LVM has between `lvextend` and `resize2fs`/`xfs_growfs`, covered in Section 030's LVM modules — a bigger logical volume does not mean a bigger filesystem until you extend the filesystem too. RAID's `--grow` plus `resize2fs`/`xfs_growfs` is the same pattern with a different first command.

> [!TIP]
> **Try it — add a disk and extend the filesystem**
>
> Wait for the previous rebuild to finish (`cat /proc/mdstat` shows no `recovery`), then:
>
> ```sh
> . /etc/playground-raid
> sudo mdadm --zero-superblock "$member2"
> sudo mdadm --manage /dev/md0 --add "$member2"
> sudo mdadm --grow /dev/md0 --raid-devices=4
> cat /proc/mdstat
> sudo mdadm --wait /dev/md0
> sudo resize2fs /dev/md0
> df -h /mnt/raid
> ```
>
> Expect something like:
>
> ```text
> md0 : active raid5 vdc[5] vde[4] vdd[3] vdb[0]
>       ... [4/4] [UUUU]
>       [==>..................]  reshape = 12% ...
>
> The filesystem on /dev/md0 is now 3139584 (1k) blocks long.
> Filesystem      Size  Used Avail Use% Mounted on
> /dev/md0        2.9G   24K  2.8G   1% /mnt/raid
> ```
>
> The re-added disk became device 5, `--grow` raised the count to 4, and the reshape redistributed data and parity. After it finished, `resize2fs` grew the ext4 filesystem into the new space and `df` shows the larger size — all with `/mnt/raid` mounted the whole time.

## Getting told when a disk fails

A degraded array is invisible unless something watches it. `mdadm --monitor` runs as a daemon (the `mdmonitor` service on most distros), polls the arrays, and on a failure or degraded state sends mail to the address in `/etc/mdadm/mdadm.conf` (`MAILADDR you@example.com`) or runs a program you specify. `--oneshot --test` sends a test notification immediately so you can confirm it works.

> [!TIP]
> **Try it — a test alert**
>
> ```sh
> sudo mdadm --monitor --scan --oneshot --test
> systemctl status mdmonitor.service --no-pager | head -n 5
> ```
>
> Expect something like:
>
> ```text
> (no output from --oneshot --test unless mail is configured; it emits a
>  "TestMessage" event for each array)
>
> ● mdmonitor.service - MD array monitor
>      Loaded: loaded (...); enabled
>      Active: active (running)
> ```
>
> `--oneshot --test` fires one `TestMessage` event per array through whatever notification path is configured. In production you set `MAILADDR` (or `PROGRAM`) in `mdadm.conf` and leave `mdmonitor` running so a real failure pages you instead of sitting silent.

> [!WARNING]
> **Common pitfalls — growth and monitoring**
>
> - **Reshaping without a backup.** `mdadm --grow` rewrites the whole array's stripe layout, in place, across every existing stripe. An interruption without `--backup-file` (on a separate device) can leave it unrecoverable. Back up the data first.
> - **Forgetting to extend the filesystem.** `--grow` makes the block device bigger; the filesystem's own superblock does not notice until `resize2fs` / `xfs_growfs` — the same two-step pattern as LVM's `lvextend` + filesystem resize.
> - **No monitoring.** Without `mdmonitor` running and `MAILADDR` set, a failed disk in a redundant array produces no alert — you find out when the second one goes, at which point Part 1's degraded-state math has nowhere left to go.

> *Growing the array is one command; growing the filesystem on top is a second, separate one — the device and the filesystem never share metadata.*

## Reference

- `man mdadm` — the `--grow` section covers `--raid-devices`, `--backup-file`, and which reshapes are supported per level.
- `man mdadm.conf` — `MAILADDR` / `PROGRAM` syntax for `--monitor` notifications.
- `man resize2fs` / `man xfs_growfs` — growing the filesystem after the block device is already bigger.
