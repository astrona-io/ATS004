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

## How this module is organised

1. **[Part 1 — Reading Health and Handling a Failure](./course-01-health-and-failure.md)** — read `/proc/mdstat` and `mdadm --detail`, understand what "degraded" actually costs per RAID level, and run the fail → remove → add → rebuild cycle.
2. **[Part 2 — Growing an Array and Getting Notified](./course-02-growth-and-monitoring.md)** — reshape a live array with `mdadm --grow`, extend the filesystem on top of it, and set up `mdadm --monitor` so a failure doesn't sit silent.

## Learning objectives

After this module you can:

- Read array health from `/proc/mdstat` and `mdadm --detail`, including the degraded state, and explain why a degraded RAID 5 array is slower and has zero remaining redundancy.
- Mark a member failed and remove it with `mdadm --manage --fail` / `--remove`.
- Add a replacement disk and monitor the rebuild.
- Grow an array onto an additional disk with `mdadm --grow`, then extend the filesystem, and explain why those are two separate steps.
- Set up failure notification with `mdadm --monitor`.

## Before you start

You need the previous module: RAID levels, `mdadm --create`, `/proc/mdstat`, and why arrays need `mdadm.conf`.

The linked playground gives you an Ubuntu server VM with a **pre-built RAID 5** at `/dev/md0` across three disks, an ext4 filesystem mounted at `/mnt/raid` with sample data, and a **fourth raw disk** as the spare. `/etc/playground-raid` records the kernel names as `member1`/`member2`/`member3`/`spare` — source that file rather than guessing device letters. Run the command blocks in each part in that VM after `astrona ssh section-030-module-04-playground`.
