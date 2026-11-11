# RAID Maintenance and Recovery

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-030/module-04/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-030/module-04/playground
> astrona destroy section-030-module-04-playground
> ```

Building an array is the easy part. The reason RAID exists is the day a disk fails: the array must keep serving data while you swap the bad disk and it rebuilds. This module covers marking a disk failed, removing and replacing it, watching the rebuild, growing an array onto another disk, and getting notified when something goes wrong.

## How this module is organised

1. **[Reading Health and Handling a Failure](./course-01-health-and-failure.md)** — reading `/proc/mdstat` and `mdadm --detail`, marking a member failed, adding a replacement, and watching the rebuild. A graded mission ends this part.
2. **[Growing an Array and Getting Notified](./course-02-growth-and-monitoring.md)** — `mdadm --grow`, extending the filesystem, and failure notification with `mdadm --monitor`. A graded mission ends this part.
3. **[Stopping, Reassembling and Reusing Disks](./course-03-stopping-and-reassembling.md)** — `mdadm --stop`, `--assemble --scan`, and clearing a disk with `--zero-superblock`. A graded mission ends this part.
4. **[Wrap-Up: Mission Debrief](./course-04-wrap-up.md)** — a recap, a self-check, and how to land the playground.

## Learning objectives

After this module you can:

- Read array health from `/proc/mdstat` and `mdadm --detail`, including the degraded state, and explain why a degraded RAID 5 array is slower and has zero remaining redundancy.
- Mark a member failed and remove it with `mdadm --manage --fail` / `--remove`.
- Add a replacement disk and monitor the rebuild.
- Grow an array onto an additional disk with `mdadm --grow`, then extend the filesystem, and explain why those are two separate steps.
- Set up failure notification with `mdadm --monitor`.
- Stop an array, assemble it again from its superblocks, and clear a disk with `mdadm --zero-superblock` before you reuse it.

## Before you start

You should know RAID levels, `mdadm --create`, `/proc/mdstat`, and why arrays need `mdadm.conf`.

The linked playground gives you an Ubuntu server VM with a **pre-built RAID 5** at `/dev/md0` across three disks, an ext4 filesystem mounted at `/mnt/raid` with sample data, and a **fourth raw disk** as the spare. `/etc/playground-raid` records the kernel names as `member1`/`member2`/`member3`/`spare` — source that file rather than guessing device letters. Run the command blocks in each part in that VM after `astrona ssh section-030-module-04-playground`.

<!-- curriculum-practice -->
## Practice and assessment

- [RAID Failure, Replacement & Rebuild Lab](labs/lab-01/question.md): Mark a RAID 5 member as failed and remove it from /dev/md0; Add the spare disk as a replacement and wait for the rebuild to finish; Confirm the array is clean with three active devices and the data file is intact.
- [RAID Grow & Failure Monitoring Lab](labs/lab-02/question.md): Add a fourth disk to the RAID 5 array and reshape it to four devices; Grow the ext4 filesystem on /dev/md0 to use the new capacity with the data file intact; Configure failure notification with a MAILADDR line in /etc/mdadm/mdadm.conf.
- [RAID Stop, Reassemble and Wipe Lab](labs/lab-03/question.md): Stop a mirror and assemble it again with its data intact; Clear a leftover RAID signature from a spare disk with --zero-superblock; Prove the spare no longer belongs to any array.
- [LVM Volume Groups and Logical Volumes Capstone Lab](../capstone/labs/lab-01/question.md): Find the physical volume that holds vol1/data1 and remove it from vol1; Create the volume group vol2 on the freed disk with a 50M logical volume named p1; Format vol2/p1 with ext4.
