# Advanced LVM Operations

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-030/module-02/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-030/module-02/playground
> astrona destroy section-030-module-02-playground
> ```

The previous module built an LVM stack. This one changes it while it is in use: moving a volume's data off a dying disk, pulling that disk out of the pool, and growing a volume and its filesystem — all with the filesystem mounted and applications writing to it.

These operations rewrite where real data lives. A wrong device name or a missing `+` sign destroys data. The commands are short; the care is in reading the current state first.

## Learning objectives

After this module you can:

- Add a disk to a live volume group with `pvcreate` + `vgextend`.
- Evacuate all extents off a physical volume with `pvmove` while its volume stays mounted.
- Remove an emptied disk from a pool with `vgreduce` and clear its LVM label with `pvremove`.
- Grow a logical volume with `lvextend` and then grow the filesystem with `resize2fs` (ext4) or `xfs_growfs` (XFS).
- Explain why `lvextend -L 20G` and `lvextend -L +20G` are dangerously different.

## Before you start

This module builds directly on the previous one. The next section recaps the pieces you need — the three LVM layers, the physical extent, and the `pvs` / `vgs` / `lvs` inspection commands — but if none of those terms are familiar, read *LVM Fundamentals* first.

The linked playground gives you an Ubuntu server VM with a **pre-built stack**: volume group `vgdata` on two 1 GB disks, logical volume `applv` (400 MiB ext4) with all its extents on the first disk, mounted at `/mnt/applv` with sample files, and a third disk left raw as the replacement. The three disks' kernel names are in `/etc/playground-disks` as `source_disk`, `second_disk`, `spare_disk` — read that file rather than assuming `vdb`/`vdc`/`vdd` order. Connect with `astrona ssh astro-section-030-module-02-playground` and run every command block below inside that VM.

## The LVM stack, recapped

The previous module built this stack from the bottom up. This module rearranges the bottom two layers while the top layer stays mounted and in use, so keep the picture in mind:

```text
  Logical volume    applv             <- what you format and mount
  -----------------------------------
  Volume group      vgdata            <- one pool of 4 MiB extents
  -----------------------------------
  Physical volumes  /dev/vdb /dev/vdc <- disks with an LVM label on them
```

- A **physical volume (PV)** is a disk or partition with a small LVM label written at its start. Only that label changes — `pvcreate` does not format the rest of the disk.
- A **volume group (VG)** pools one or more PVs into a single space, divided into **physical extents (PEs)** of 4 MiB each. Every allocation LVM makes is a whole number of extents.
- A **logical volume (LV)** is a run of extents handed out from the VG. It appears at `/dev/<vg>/<lv>` and behaves exactly like a partition. Its extents can come from several PVs at once, and the filesystem stacked on top cannot tell the difference.

`vgdata` in this playground is a VG built on two PVs, with one LV, `applv`, carved from it.

### Reading the command names

Every LVM command is a **layer prefix** — `pv`, `vg`, or `lv` — followed by an **action**. The prefix says which layer you are touching; the suffix says what you are doing to it. Once that clicks, the names read themselves: `vgextend` is "volume group, extend"; `pvremove` is "physical volume, remove"; `lvs` is "logical volumes, short list".

| Action              | On a PV (`pv…`) | On a VG (`vg…`) | On an LV (`lv…`) |
|---------------------|-----------------|-----------------|-----------------|
| create it           | `pvcreate`      | `vgcreate`      | `lvcreate`      |
| list, one line each  | `pvs`           | `vgs`           | `lvs`           |
| list, full detail   | `pvdisplay`     | `vgdisplay`     | `lvdisplay`     |
| add capacity        | —               | `vgextend`      | `lvextend`      |
| take a member out   | —               | `vgreduce`      | —               |
| wipe / destroy it   | `pvremove`      | `vgremove`      | `lvremove`      |
| relocate extents    | `pvmove`        | —               | —               |

Two patterns cover almost everything in this module:

- **Build upward, tear down from the top.** Growing the stack runs `pvcreate` → `vgextend` → `lvextend`. Retiring a disk runs the other way: `pvmove` the data off it, `vgreduce` the disk out of the pool, `pvremove` the label. Each teardown verb is the exact inverse of a build verb — `vgreduce` undoes `vgextend`, `pvremove` undoes `pvcreate`.
- **`…s` for a glance, `…display` for the full record.** `pvs`, `vgs`, and `lvs` print one line per object with the columns you check most often; the `…display` forms print everything.

`pvmove` is the odd one out — extents are a PV-level idea, so there is no `vgmove` or `lvmove`. You name the PV to drain, and LVM moves whatever LVs happen to have extents on it.

The three `…s` commands are what you run before and after every change here:

- **`pvs`** — one line per PV: which disk, which VG it belongs to (blank if none), its size, and how much is free.
- **`vgs`** — one line per VG: how many PVs and LVs it holds, its total size, its free size.
- **`lvs`** — one line per LV: name, VG, size. Add `-o +devices` to append the PVs its extents currently sit on — the single most important thing to know before a `pvmove`.

You will see all three in the first checkpoint below.

## Reading the current state

Every operation here depends on knowing which extents are where. Before touching anything, look.

> [!TIP]
> **Try it — survey the stack**
>
> ```sh
> cat /etc/playground-disks
> sudo pvs
> sudo vgs
> sudo lvs -o +devices
> df -h /mnt/applv
> ```
>
> Expect something like:
>
> ```text
> source_disk=/dev/vdb   # holds all of applv's extents (the 'failing' disk)
> second_disk=/dev/vdc
> spare_disk=/dev/vdd
>
>   PV         VG     Fmt  Attr PSize    PFree
>   /dev/vdb   vgdata lvm2 a--  1020.00m 620.00m
>   /dev/vdc   vgdata lvm2 a--  1020.00m 1020.00m
>
>   LV    VG     Attr       LSize   Devices
>   applv vgdata -wi-ao---- 400.00m /dev/vdb(0)
>
>   Filesystem               Size  Used Avail Use% Mounted on
>   /dev/mapper/vgdata-applv 380M   14K  350M   1% /mnt/applv
> ```
>
> `lvs -o +devices` confirms every extent of `applv` is on `source_disk` (`/dev/vdb` here). `spare_disk` is not listed by `pvs` at all — it is still raw. That is the situation the rest of the chapter changes.

## Adding a replacement disk to the pool

A disk that is throwing SMART warnings has not failed yet, so you can still read from it. The migration strategy is: add a healthy disk to the same VG, move the data across, then drop the sick one.

This is the "build upward" pattern from the recap, stopping one layer short of the LV:

- `pvcreate <spare>` writes an LVM label to the front of the raw disk. It goes from "not LVM's" to "a PV that belongs to no VG yet". Nothing else on the disk is touched, but the disk must hold no data you want to keep.
- `vgextend <vg> <spare>` hands that PV to an existing volume group. LVM slices it into 4 MiB extents and adds them to the pool's free space. It is the mirror image of `vgreduce`, which you run later to take the disk back out.

Both commands are safe on a running system — they add capacity without moving a single byte of existing data, so no LV and no filesystem is affected.

> [!TIP]
> **Try it — extend the volume group onto the spare**
>
> ```sh
> . /etc/playground-disks
> sudo pvcreate "$spare_disk"
> sudo vgextend vgdata "$spare_disk"
> sudo vgs
> sudo pvs
> ```
>
> Expect something like:
>
> ```text
>   Physical volume "/dev/vdd" successfully created.
>   Volume group "vgdata" successfully extended
>
>   VG     #PV #LV #SN Attr   VSize  VFree
>   vgdata   3   0   1 wz--n- <2.99g <2.61g
> ```
>
> `vgdata` now spans three PVs and its free space jumped by ~1 GB. Nothing about `applv` changed yet — you only added room.

## Migrating extents with `pvmove`

`pvmove <source>` walks every allocated extent on `<source>`, copies it to free space on the other PVs in the same VG, and rewrites LVM's map to point at the new location — one extent at a time. Because the map is updated as it goes, the LV never has a gap: if an application writes to a block that is mid-copy, LVM applies the write to the new location and continues. The mounted filesystem sees nothing but its own normal I/O.

`pvmove` is the only "relocate" verb in LVM — there is no `vgmove` or `lvmove` — because extents are a property of the PV they sit on. You point it at the disk you want emptied, not at a volume; it moves whichever LVs have extents there.

It can take a while on a real disk and prints a running percentage. If it is interrupted (a reboot, a Ctrl-C), re-running the same command resumes from where it stopped. Give it somewhere to go first: it needs enough free extents on the *other* PVs in the VG, which is why `vgextend` with the spare comes before it.

> [!TIP]
> **Try it — evacuate the source disk while applv stays mounted**
>
> ```sh
> . /etc/playground-disks
> sudo pvmove "$source_disk"
> sudo lvs -o +devices
> cat /mnt/applv/data.txt
> df -h /mnt/applv
> ```
>
> Expect something like:
>
> ```text
>   /dev/vdb: Moved: 4.00%
>   /dev/vdb: Moved: 71.00%
>   /dev/vdb: Moved: 100.00%
>
>   LV    VG     Attr       LSize   Devices
>   applv vgdata -wi-ao---- 400.00m /dev/vdc(0),/dev/vdd(0)
>
> important production data
> ```
>
> `applv`'s extents are now on `second_disk` and `spare_disk`; none remain on `source_disk`. The file is intact and `df` is unchanged — the migration happened underneath a live, mounted filesystem.

## Removing the emptied disk

With no extents left on it, `source_disk` can leave the pool. This is the "tear down from the top" half of the recap, undoing the two build steps in reverse:

- `vgreduce <vg> <source>` detaches the PV from the volume group — the inverse of `vgextend`. It only succeeds when the PV is empty, which is what the `pvmove` guaranteed.
- `pvremove <source>` erases the LVM label written by `pvcreate`, returning the disk to a plain, unclaimed state that is safe to physically unplug or repurpose.

Order matters: `pvremove` refuses to run on a disk that is still a VG member, so `vgreduce` has to come first.

> [!TIP]
> **Try it — retire the source disk**
>
> ```sh
> . /etc/playground-disks
> sudo vgreduce vgdata "$source_disk"
> sudo pvremove "$source_disk"
> sudo pvs
> sudo vgs
> ```
>
> Expect something like:
>
> ```text
>   Removed "/dev/vdb" from volume group "vgdata"
>   Labels on physical volume "/dev/vdb" successfully wiped.
>
>   PV         VG     Fmt  Attr PSize    PFree
>   /dev/vdc   vgdata lvm2 a--  1020.00m  620.00m
>   /dev/vdd   vgdata lvm2 a--  1020.00m  620.00m
>
>   VG     #PV #LV #SN Attr   VSize  VFree
>   vgdata   2   0   1 wz--n-  1.99g  1.21g
> ```
>
> `source_disk` no longer appears in `pvs`, and `vgdata` is back to two PVs — the sick disk is fully removed with no downtime taken.

## Growing a volume live: `lvextend` then the filesystem

Enlarging a mounted volume is two steps, in order: grow the block device, then grow the filesystem inside it. The first step is `lvextend` — the LV-layer counterpart of `vgextend`, one level up the stack. `vgextend` adds a disk's extents to the *pool*; `lvextend` hands some of the pool's free extents to a *volume*.

`lvextend -L +<size> <lv-path>` adds space. Unlike `vgextend`, it takes a size, and the `+` is critical:

- `lvextend -L +200M /dev/vgdata/applv` — **add** 200 MiB to the current size.
- `lvextend -L 200M /dev/vgdata/applv` — set the absolute size **to** 200 MiB. If `applv` is 400 MiB, this shrinks it and truncates the filesystem, destroying data.

After the LV is bigger, the filesystem still thinks it ends at the old boundary. Grow it: `resize2fs <lv-path>` for ext4, or `xfs_growfs <mountpoint>` for XFS (XFS takes the mount point, not the device, and can only grow, never shrink). `lvextend -r` will call the right resize tool for you in one step.

> [!TIP]
> **Try it — add space and extend the ext4 filesystem**
>
> ```sh
> df -h /mnt/applv
> sudo lvextend -L +200M /dev/vgdata/applv
> df -h /mnt/applv
> sudo resize2fs /dev/vgdata/applv
> df -h /mnt/applv
> ```
>
> Expect something like:
>
> ```text
> /dev/mapper/vgdata-applv 380M ... 350M   1% /mnt/applv
>
>   Size of logical volume vgdata/applv changed from 400.00 MiB to 600.00 MiB.
>
> /dev/mapper/vgdata-applv 380M ... 350M   1% /mnt/applv     <-- LV bigger, FS not yet
>
> The filesystem on /dev/vgdata/applv is now 614400 (1k) blocks long.
>
> /dev/mapper/vgdata-applv 570M ... 540M   1% /mnt/applv     <-- FS now uses the space
> ```
>
> After `lvextend` the block device is 600 MiB but `df` is unchanged — the filesystem has not noticed. `resize2fs` extends it online and `df` jumps. The playground's filesystem is ext4; on XFS you would run `sudo xfs_growfs /mnt/applv` instead and see the same result.

> [!WARNING]
> **Common pitfalls**
>
> - **`lvextend -L 20G` without the `+`.** That sets the absolute size. On a volume already larger than 20G it shrinks and truncates, destroying data with no prompt. Always write `-L +20G` to add.
> - **Forgetting the filesystem step.** `lvextend` alone leaves the extra space unusable — the filesystem still ends at the old size. Follow with `resize2fs` / `xfs_growfs`, or use `lvextend -r`.
> - **`pvmove` with nowhere to move to.** It needs enough free extents on the *other* PVs in the VG. Run `vgextend` with a fresh disk first if the pool is nearly full.
> - **`pvremove` before `vgreduce`.** A PV still in a VG will not `pvremove` cleanly. Detach it with `vgreduce` first, and only after `pvmove` has emptied it.
> - **Assuming XFS can shrink.** `resize2fs` can grow or shrink ext4 (shrink offline); `xfs_growfs` only grows. There is no supported XFS shrink — plan capacity accordingly.
