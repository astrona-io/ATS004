# RAID Maintenance and Recovery

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-030/module-04/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-030/module-04/playground
> astrona destroy section-030-module-04-playground
> ```

Building an array (previous module) is the easy part. The reason RAID exists is the day a disk fails: the array must keep serving data while you swap the bad disk and it rebuilds. This module covers marking a disk failed, removing and replacing it, watching the rebuild, growing an array onto another disk, and getting notified when something goes wrong.

## Learning objectives

After this module you can:

- Read array health from `/proc/mdstat` and `mdadm --detail`, including the degraded state.
- Mark a member failed and remove it with `mdadm --manage --fail` / `--remove`.
- Add a replacement disk and monitor the rebuild.
- Grow an array onto an additional disk with `mdadm --grow`, then extend the filesystem.
- Set up failure notification with `mdadm --monitor`.

## Before you start

You need the previous module: RAID levels, `mdadm --create`, `/proc/mdstat`, and why arrays need `mdadm.conf`.

The linked playground gives you an Ubuntu server VM with a **pre-built RAID 5** at `/dev/md0` across three disks, an ext4 filesystem mounted at `/mnt/raid` with sample data, and a **fourth raw disk** as the spare. `/etc/playground-raid` records the kernel names as `member1`/`member2`/`member3`/`spare` — source that file rather than guessing device letters. Run the command blocks below in that VM after `astrona ssh section-030-module-04-playground`.

## Reading array health

Two views. `/proc/mdstat` is the quick status: the level, the member list, and a bracket map like `[UUU]` — one character per device, `U` for up, `_` for missing. `mdadm --detail /dev/md0` is the full report: state, per-device role and status, and rebuild progress.

> [!TIP]
> **Try it — the healthy baseline**
>
> ```sh
> cat /proc/mdstat
> sudo mdadm --detail /dev/md0 | grep -E 'State|Devices|Rebuild'
> cat /mnt/raid/data.txt
> ```
>
> Expect something like:
>
> ```text
> md0 : active raid5 vdd[3] vdc[1] vdb[0]
>       2093056 blocks super 1.2 level 5, 512k chunk, algorithm 2 [3/3] [UUU]
>
>              State : clean
>      Raid Devices : 3
>     Total Devices : 3
>     Active Devices : 3
>   Working Devices : 3
>    Failed Devices : 0
>
> critical dataset row 1
> ```
>
> `[3/3] [UUU]` and `State : clean` — all three members up, RAID 5 giving ~2 GB usable (two disks' worth; the third holds parity, distributed). The data file reads normally.

## Failing and removing a disk

When a disk throws errors, `mdadm` often marks it failed on its own. You can also do it manually — before pulling a disk for replacement, or to test. `mdadm --manage /dev/md0 --fail <device>` marks a member faulty; the array immediately drops to **degraded**: still serving data (RAID 5 tolerates one loss), but with no remaining redundancy. `--remove` then detaches the failed member so a new one can take its slot.

> [!TIP]
> **Try it — degrade the array on purpose**
>
> ```sh
> . /etc/playground-raid
> sudo mdadm --manage /dev/md0 --fail "$member2"
> cat /proc/mdstat
> sudo mdadm --manage /dev/md0 --remove "$member2"
> cat /mnt/raid/data.txt
> ```
>
> Expect something like:
>
> ```text
> md0 : active raid5 vdd[3] vdc[1](F) vdb[0]
>       2093056 blocks ... [3/2] [U_U]
>
> critical dataset row 1
> ```
>
> `(F)` marks the failed member and the map is now `[U_U]` — `[3/2]`, one device short. The file still reads: RAID 5 reconstructs the missing data from parity on the fly. This is the window where a *second* failure would lose everything, so replacement is urgent.

## Adding a replacement and rebuilding

`mdadm --manage /dev/md0 --add <device>` puts a fresh disk into the empty slot. `md` immediately starts a **rebuild**: reading every surviving disk and computing what belonged on the new one. `/proc/mdstat` shows a `recovery` progress line. The array stays usable throughout, just slower and still degraded until the rebuild completes.

> [!TIP]
> **Try it — replace and watch the rebuild**
>
> ```sh
> . /etc/playground-raid
> sudo mdadm --manage /dev/md0 --add "$spare"
> cat /proc/mdstat
> sudo mdadm --detail /dev/md0 | grep -E 'State|Rebuild'
> ```
>
> Expect something like:
>
> ```text
> md0 : active raid5 vde[4] vdd[3] vdb[0]
>       2093056 blocks ... [3/2] [U_U]
>       [=====>...............]  recovery = 27% (280000/1046528) finish=0.4min ...
>
>              State : clean, degraded, recovering
> ```
>
> The spare (`vde` here) joined as device 4 and the `recovery` line is climbing. When it reaches 100%, the map returns to `[UUU]` and `State` goes back to `clean`. On a real multi-terabyte array this takes hours and hammers the surviving disks — which is why a second failure during a RAID 5 rebuild is a classic way to lose an array.

## Growing an array

`mdadm --grow` reshapes a live array. The common case is adding capacity: put another disk in and raise the device count. RAID 5 with 3 disks (2 usable) becomes 4 disks (3 usable). The reshape rewrites the stripe layout across all disks — slow, and it should not be interrupted, so **back up first** and, for parity levels, pass `--backup-file=` on a *separate* disk to make an interrupted reshape resumable.

After the array is bigger, the filesystem on it still ends at the old size — extend it with `resize2fs` (ext4) or `xfs_growfs` (XFS), exactly as for LVM in Section 030.

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
> **Common pitfalls**
>
> - **`--fail` on a non-redundant array.** `--fail` a member of a RAID 0, or the *second* member of a degraded RAID 5, and the array is dead. `--fail` is only safe while redundancy remains.
> - **Not replacing a failed disk promptly.** A degraded array has no safety margin. The rebuild window and the "waiting for a replacement" window are both times a second failure is fatal — especially on RAID 5.
> - **Reshaping without a backup.** `mdadm --grow` rewrites the whole array layout. An interruption without `--backup-file` (on a separate device) can leave it unrecoverable. Back up the data first.
> - **Forgetting to extend the filesystem.** `--grow` makes the block device bigger; the filesystem does not notice until `resize2fs` / `xfs_growfs`.
> - **Re-adding a disk that still has its old superblock.** `mdadm --zero-superblock <device>` before `--add`, or it may be misidentified.
> - **No monitoring.** Without `mdmonitor` running and `MAILADDR` set, a failed disk in a redundant array produces no alert — you find out when the second one goes.
