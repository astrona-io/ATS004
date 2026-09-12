# Part 1 — The LVM Stack, Recapped & Reading State

> Prerequisite: [Module landing page](./course.md). Next: [Part 2 — Live Migration: pvmove](./course-02-pvmove-migration.md).

Every operation later in this module — moving data off a dying disk, retiring it, growing a volume live — is a rearrangement of one underlying structure: a list of extents. This part pins down exactly what that structure is and how to read it with `pvs`/`vgs`/`lvs`, because every command after this one only makes sense in terms of it.

## The extent is the unit of everything

The previous module built the three-layer stack:

```text
  Logical volume    shared_documents  <- what you format and mount
  -----------------------------------
  Volume group      company_storage   <- one pool of 4 MiB extents
  -----------------------------------
  Physical volumes  /dev/vdc /dev/vdd  <- disks with an LVM label on them
```

- A **physical volume (PV)** is a disk or partition with a small LVM label written at its start (`pvcreate` writes only that label — nothing else on the disk is touched).
- A **volume group (VG)** pools one or more PVs and divides the pooled space into **physical extents (PEs)**, fixed-size chunks (4 MiB by default). Every allocation LVM makes is a whole number of extents — never a byte range.
- A **logical volume (LV)** is not a region of disk. It is a **list of extent assignments** stored in the VG's metadata area: `(this PV, extent N) → (this LV, extent M)`, repeated for every extent the LV owns. `/dev/<vg>/<lv>` is a device-mapper target built by replaying that list at activation time.

That list-of-pointers model is the single fact that explains everything downstream:

- An LV's extents do not need to be contiguous, or even on the same PV. `shared_documents`'s 100 extents could be 60 on one disk and 40 on another, and the filesystem on top would never know — device-mapper stitches the list into one linear address space.
- **Relocating** an extent means changing one entry in that list and copying the data it points to — not moving a filesystem, not touching mount state. That is the entire mechanism behind `pvmove`, covered in Part 2.
- **Adding capacity to an LV** means appending more entries to its list, drawn from whichever PVs currently have free extents. That is `lvextend`, covered in Part 3.
- **Removing a PV from a VG** is only safe once zero of its extents appear in *any* LV's list — otherwise removing it would leave dangling pointers. That is the rule `vgreduce` enforces, also in Part 3.

## Reading the command names

Every LVM command is a **layer prefix** (`pv`, `vg`, or `lv`) followed by an **action**. The prefix says which layer's extent-bookkeeping you are touching; the suffix says what you are doing to it.

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

- **Build upward, tear down from the top.** Growing the stack runs `pvcreate` → `vgextend` → `lvextend`. Retiring a disk runs the other way: `pvmove` the data off it, `vgreduce` the disk out of the pool, `pvremove` the label. Each teardown verb is the exact inverse of a build verb.
- **`…s` for a glance, `…display` for the full record.** `pvs`, `vgs`, `lvs` print one line per object with the columns you check most often; the `…display` forms print everything, including the raw extent list.

`pvmove` has no `vgmove` / `lvmove` counterpart, because extents are a property of the **PV** they currently sit on — you name the PV to drain, and LVM figures out from the extent list which LVs happen to have entries pointing at it.

## The three inspection commands

- **`pvs`** — one line per PV: which disk, which VG it belongs to (blank if none), size, free space.
- **`vgs`** — one line per VG: PV count, LV count, total size, free size.
- **`lvs`** — one line per LV: name, VG, size. `-o +devices` appends *where its extents currently are* — reading the extent-assignment list directly. This is the single most important column to check before a `pvmove`, and the one that proves a migration finished.

> [!TIP]
> **Try it — survey the stack**
>
> On `astro-section-030-module-02-playground` (`astrona ssh` in). Disk letters and exact free-space figures will vary on your VM — that's expected, LVM assigns them at boot.
>
> **1. Read the kernel disk names the bootstrap script recorded, so you don't have to guess `vdX` order:**
> ```sh
> cat /etc/playground-disks
> ```
> ```text
> source_disk=/dev/vdc   # holds all of shared_documents's extents (the 'failing' disk)
> second_disk=/dev/vdd   # also in company_storage
> spare_disk=/dev/vde    # raw, not yet a PV
> ```
> These three lines are just plain shell variable assignments, written by the playground's setup script — not LVM output. `source_disk` and `second_disk` are the two PVs already pooled into the VG; `spare_disk` is a third disk left untouched for Part 2.
>
> **2. List the physical volumes:**
> ```sh
> sudo pvs
> ```
> ```text
>   PV        VG              Fmt  Attr PSize    PFree
>   /dev/vdc  company_storage lvm2 a--  1020.00m  620.00m
>   /dev/vdd  company_storage lvm2 a--  1020.00m 1020.00m
> ```
> Only two rows, both showing `VG = company_storage`. `spare_disk` (`/dev/vde`) is raw, not yet a PV, so it doesn't appear here at all — `pvs` only ever lists disks that have been through `pvcreate`.
>
> **3. List the volume group:**
> ```sh
> sudo vgs
> ```
> ```text
>   VG               #PV #LV #SN Attr   VSize VFree
>   company_storage   2   1   0 wz--n- 1.99g 1.60g
> ```
> `#PV 2` matches the two rows from step 2. `#LV 1` — one logical volume has been carved out already (this playground starts pre-built, unlike Module 1's from-scratch walkthrough). `#SN 0` means no snapshots exist.
>
> **4. List logical volumes with their extent locations:**
> ```sh
> sudo lvs -o +devices
> ```
> ```text
>   LV                VG              Attr       LSize   Devices
>   shared_documents  company_storage -wi-ao---- 400.00m /dev/vdc(0)
> ```
> `Devices` is the field this whole module revolves around: it confirms every extent of `shared_documents` currently lives on `source_disk` (`/dev/vdc`). `/dev/vdc(0)` means "starting from physical extent 0 of that PV" — that single field is literally the extent-assignment list for this LV, printed in shorthand.
>
> **5. Confirm the filesystem is mounted and see its usage:**
> ```sh
> df -h /mnt/shared_documents
> ```
> ```text
>   Filesystem                                    Size  Used Avail Use% Mounted on
>   /dev/mapper/company_storage-shared_documents  359M   36K  331M   1% /mnt/shared_documents
> ```
> An ordinary mounted ext4 filesystem, exactly like Module 1 ended with — this confirms the pre-built stack is live and usable before Part 2 starts moving its extents around.

> *The LV is not where its data lives — it's a list of where each of its extents lives, and every command in this module edits that list.*

## Reference

- `man lvs` — the full column reference for `-o`; `devices` is the one worth memorizing.
- `man lvm` — the top-level man page describing the PV/VG/LV/PE terminology this whole module builds on.
