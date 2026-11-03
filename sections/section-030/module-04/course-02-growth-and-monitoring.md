# Growing an Array and Getting Notified

A healthy, rebuilt array is still fixed-size. This part covers adding capacity to a live array with `mdadm --grow`, why the filesystem on top does not notice until you tell it to, and setting up `mdadm --monitor` so a future failure does not sit silent until a second disk goes.

## Growing an array

`mdadm --grow` reshapes a live array. The common case is adding capacity: put another disk in and raise the device count. RAID 5 with 3 disks (2 usable) becomes 4 disks (3 usable).

Under the hood, RAID 5's stripe geometry is not just "more disks" — every stripe's data-plus-parity layout has to be recalculated across the *new* member count, and every existing stripe on disk has to be read, recomputed, and rewritten into the new layout. That rewrite touches the entire array, not just new space, which is why it is slow and why it must not be interrupted partway: an interrupted reshape can leave some stripes in the old layout and some in the new, with no record of where the boundary was. `--backup-file=<path>` (on a *separate* device, never a member of the array) checkpoints the in-progress region so an interrupted reshape can resume from where it left off instead of losing track. Back up your data first regardless — this is not a substitute for a backup, only for resumability.

## The block device and the filesystem grow separately

After `--grow` finishes, `/dev/md0` **is** bigger — `lsblk` and `blockdev --getsize64` see it immediately. But the ext4 (or XFS) filesystem sitting on top has its own size recorded in its own superblock, written when it was created, and it has no way of noticing the block device underneath it changed shape. Growing the device and growing the filesystem are two separate operations against two separate pieces of metadata, and only you connect them.

A bigger array does not mean a bigger filesystem until you extend the filesystem too: `--grow` first, then `resize2fs` (ext4) or `xfs_growfs` (XFS).

### See it in your playground

Wait for the previous rebuild to finish (`cat /proc/mdstat` shows no `recovery`), then:

<!-- astrona:playground:renew -->

```sh
. /etc/playground-raid
sudo mdadm --zero-superblock "$member2"
sudo mdadm --manage /dev/md0 --add "$member2"
sudo mdadm --grow /dev/md0 --raid-devices=4
cat /proc/mdstat
sudo mdadm --wait /dev/md0
sudo resize2fs /dev/md0
df -h /mnt/raid
```

Expect something like:

```text
md0 : active raid5 vdc[5] vde[4] vdd[3] vdb[0]
      ... [4/4] [UUUU]
      [==>..................]  reshape = 12% ...

The filesystem on /dev/md0 is now 3139584 (1k) blocks long.
Filesystem      Size  Used Avail Use% Mounted on
/dev/md0        2.9G   24K  2.8G   1% /mnt/raid
```

The re-added disk became device 5, `--grow` raised the count to 4, and the reshape redistributed data and parity. After it finished, `resize2fs` grew the ext4 filesystem into the new space and `df` shows the larger size — all with `/mnt/raid` mounted the whole time.

## Getting told when a disk fails

A degraded array is invisible unless something watches it. `mdadm --monitor` runs as a daemon (the `mdmonitor` service on most distros), polls the arrays, and on a failure or degraded state sends mail to the address in `/etc/mdadm/mdadm.conf` (`MAILADDR you@example.com`) or runs a program you specify. `--oneshot --test` sends a test notification immediately so you can confirm it works.

### See it in your playground

```sh
sudo mdadm --monitor --scan --oneshot --test
systemctl status mdmonitor.service --no-pager | head -n 5
```

Expect something like:

```text
(no output from --oneshot --test unless mail is configured; it emits a
 "TestMessage" event for each array)

● mdmonitor.service - MD array monitor
     Loaded: loaded (...); enabled
     Active: active (running)
```

`--oneshot --test` fires one `TestMessage` event per array through whatever notification path is configured. In production you set `MAILADDR` (or `PROGRAM`) in `mdadm.conf` and leave `mdmonitor` running so a real failure pages you instead of sitting silent.

> *Growing the array is one command; growing the filesystem on top is a second, separate one — the device and the filesystem never share metadata.*

## Common pitfalls

> [!WARNING]
>
> - **Reshaping without a backup.** `mdadm --grow` rewrites the whole array's stripe layout, in place, across every existing stripe. An interruption without `--backup-file` (on a separate device) can leave it unrecoverable. Back up the data first.
> - **Forgetting to extend the filesystem.** `--grow` makes the block device bigger; the filesystem's own superblock does not notice until `resize2fs` / `xfs_growfs`.
> - **No monitoring.** Without `mdmonitor` running and `MAILADDR` set, a failed disk in a redundant array produces no alert — you find out when the second one goes, at which point the degraded-state math has nowhere left to go.

## Your mission: RAID Grow & Failure Monitoring Lab

You can now grow an array onto a new disk, extend the filesystem, and set up failure notification. The mission asks you to add a spare and grow the array to 4 devices. The disk names are in `/etc/lab036-raid`.

The mission runs on its own training ship. A playground cannot be paused, so remove it first to free memory; it always starts clean again:

```sh
astrona destroy section-030-module-04-playground
```

Then start the mission and connect to it:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-030/module-04/labs/lab-02
astrona ssh ats-004-lab-036
```

Read the task in [`question.md`](./labs/lab-02/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-030/module-04/labs/lab-02
```

When the mission is done, remove it and start a fresh playground:

```sh
astrona destroy ats-004-lab-036
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-030/module-04/playground
```
