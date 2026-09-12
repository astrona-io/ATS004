# Part 2 — Live Migration: pvmove

> Prerequisite: [Part 1 — The LVM Stack, Recapped & Reading State](./course-01-stack-and-state.md). Next: [Part 3 — Shrinking and Growing: vgreduce, lvextend](./course-03-vgreduce-lvextend.md).

Part 1 established that an LV is a list of extent assignments. This part covers the operation that edits that list while the filesystem on top stays mounted and being written to: evacuating every extent off one PV so the disk underneath can be pulled.

## Give it somewhere to go first

A disk throwing SMART warnings has not failed yet — you can still read from it, which is exactly what a live migration needs. The strategy is: add a healthy disk to the same VG, move the data across, then drop the sick one. This is the "build upward" pattern from Part 1, stopping one layer short of the LV:

- `pvcreate <spare>` writes an LVM label to the front of the raw disk — from "not LVM's" to "a PV that belongs to no VG yet". The disk must hold no data you want to keep; nothing else on it is touched.
- `vgextend <vg> <spare>` hands that PV to an existing volume group. LVM slices it into extents and adds them to the pool's free space — the mirror image of `vgreduce`, covered in Part 3.

Both commands only add free extents to the pool's bookkeeping. No LV's extent list changes, so no filesystem is affected — this step is uneventful by design.

> [!TIP]
> **Try it — extend the volume group onto the spare**
>
> ```sh
> . /etc/playground-disks
> sudo pvcreate "$spare_disk"
> sudo vgextend company_storage "$spare_disk"
> sudo vgs
> sudo pvs
> ```
>
> Expect something like:
>
> ```text
>   Physical volume "/dev/vde" successfully created.
>   Volume group "company_storage" successfully extended
>
>   VG               #PV #LV #SN Attr   VSize  VFree
>   company_storage   3   1   0 wz--n- <2.99g <2.60g
>
>   PV        VG              Fmt  Attr PSize    PFree
>   /dev/vdc  company_storage lvm2 a--  1020.00m  620.00m
>   /dev/vdd  company_storage lvm2 a--  1020.00m 1020.00m
>   /dev/vde  company_storage lvm2 a--  1020.00m 1020.00m
> ```
>
> `company_storage` now spans three PVs (`#PV 3`); the spare shows a `VG` of `company_storage` with all its space free. `#LV` is still `1` — nothing about `shared_documents`'s extent list changed. You only gave the pool somewhere to send data to.

## What `pvmove` actually does

`pvmove <source>` walks every extent the VG metadata assigns to `<source>`, and for each one:

1. Allocates a free extent on another PV in the VG.
2. Mirrors that one extent — the new copy stays in sync with the old while the copy is in progress, using the same live-mirroring machinery `mdadm` RAID 1 uses underneath (a temporary device-mapper mirror target, one per extent in flight).
3. Once the mirror reports in-sync, atomically flips the LV's extent-list entry to point at the new location and tears down the temporary mirror for that extent.

Because each extent is mirrored — not simply copied-then-cut-over — a write from a running application during the copy lands on **both** the old and new location until the flip, and after the flip the extent-list update is atomic. There is no window where an in-flight write could be lost or where the LV's map is inconsistent. This is also why a `pvmove` interrupted mid-run (a reboot, a `Ctrl-C`) is safe to resume: re-running the same command picks up wherever the extent list says it left off, because the list itself is the only source of truth about what has and has not moved yet.

`pvmove` is the only "relocate" verb in LVM — no `vgmove`, no `lvmove` — because extents are a property of the PV they currently sit on, not of a VG or LV as a whole. You name the PV to drain; LVM consults the extent list to find whichever LVs happen to have entries pointing at it, and moves those.

It needs somewhere to put the data: enough free extents on the *other* PVs in the VG, which is why `vgextend` with the spare has to happen first.

> [!TIP]
> **Try it — evacuate the source disk while shared_documents stays mounted**
>
> ```sh
> . /etc/playground-disks
> sudo pvmove "$source_disk"
> sudo lvs -o +devices
> cat /mnt/shared_documents/data.txt
> df -h /mnt/shared_documents
> ```
>
> Expect something like (the percentage lines and where the extents land both vary):
>
> ```text
>   /dev/vdc: Moved: 29.00%
>   /dev/vdc: Moved: 100.00%
>
>   LV                VG              Attr       LSize   Devices
>   shared_documents  company_storage -wi-ao---- 400.00m /dev/vdd(0)
>
> important production data
> ```
>
> `lvs -o +devices` is Part 1's extent-list column again — now it reads `/dev/vdd(0)` instead of `/dev/vdc(0)`: every entry in `shared_documents`'s list has been rewritten to point at the new PV. Here they all landed on `second_disk` because it had one contiguous free run big enough; if no single PV had room, `Devices` would list two or more, e.g. `/dev/vdd(0),/dev/vde(0)` — a perfectly normal, if messier, extent list. The file is intact and `df` is unchanged: from the filesystem's point of view, nothing happened.

> *`pvmove` never "copies a disk" — it mirrors and re-points one extent at a time, which is what makes it both live-safe and resumable.*

## Reference

- `man pvmove` — covers `--abort` (cancel and roll back an in-progress move) and `-b` (background it and poll with `pvmove` alone to check status).
- `man lvm.conf` — `activation/mirror_image_fault_policy` and related settings, if you ever need to tune how LVM's mirror machinery behaves under I/O errors during a move.
