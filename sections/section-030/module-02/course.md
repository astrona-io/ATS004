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

You need the previous module's material: what PVs, VGs, LVs, and extents are, and the `pvs` / `vgs` / `lvs` inspection commands.

The linked playground gives you an Ubuntu server VM with a **pre-built stack**: volume group `vgdata` on two 1 GB disks, logical volume `applv` (400 MiB ext4) with all its extents on the first disk, mounted at `/mnt/applv` with sample files, and a third disk left raw as the replacement. The three disks' kernel names are in `/etc/playground-disks` as `source_disk`, `second_disk`, `spare_disk` — read that file rather than assuming `vdb`/`vdc`/`vdd` order. Run the command blocks below in that VM after `astrona ssh section-030-module-02-playground`.

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

`pvcreate <spare>` initialises the new disk as a PV; `vgextend <vg> <spare>` folds it into the existing pool. Both are safe on a running system — they add capacity without moving anything.

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

`pvmove <source>` copies every allocated extent off `<source>` onto other PVs in the same VG that have free space, updating LVM's map as it goes. If an application writes to a block mid-copy, LVM applies the write to the new location and carries on. The mounted filesystem sees nothing.

It can take a while and prints progress. You can re-run it if interrupted; it resumes.

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

With no extents left on it, `source_disk` can leave the pool. `vgreduce <vg> <source>` detaches it; `pvremove <source>` wipes the LVM label so the disk is plain again and safe to physically pull.

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

Enlarging a mounted volume is two steps, in order: grow the block device, then grow the filesystem inside it.

`lvextend -L +<size> <lv-path>` adds space. The `+` is critical:

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
