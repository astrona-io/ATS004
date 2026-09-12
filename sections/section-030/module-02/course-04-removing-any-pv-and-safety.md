# Part 4 — Removing Any PV, and Physical Disk Safety

> Prerequisite: [Part 3 — vgreduce, and Growing/Shrinking a Volume](./course-03-vgreduce-lvextend.md). Next: [Module landing page](./course.md).

Parts 2–3 walked through one specific scenario: a single disk holding 100% of an LV's data, evacuated onto one freshly-added spare. Real volume groups are often built from three, four, or more disks, and an LV's extents can already be spread across several of them long before you ever need to pull one. This part covers two things the earlier, narrower scenario left out: how `pvmove`/`vgreduce`/`pvremove` generalize to a VG of any size with data spread any way, and what "safe to unplug" actually requires once LVM's own bookkeeping is done.

## The same three commands, regardless of how many PVs there are

Nothing about `pvmove`, `vgreduce`, or `pvremove` cares whether a VG has two PVs or twelve, or whether the PV you're removing holds all of an LV's extents, half of them, or a sliver mixed in among several other disks. The procedure is always the same:

1. `pvmove <the-one-PV-you're-removing>` — moves *only that PV's* extents elsewhere in the VG, no matter how many other PVs already hold pieces of the same LV or different LVs entirely.
2. `vgreduce <vg> <that-PV>` — detaches it, once step 1 leaves it with zero extents.
3. `pvremove <that-PV>` — wipes its LVM label.

The one thing worth checking *before* step 1, that Part 2's single-spare scenario didn't need to: does the rest of the VG actually have room? `pvmove` needs free extents on the VG's *other* PVs at least equal to however much the PV you're draining currently holds. A quick way to check both sides at once:

```sh
sudo pvs -o pv_name,pv_used,pv_free
```

Compare the `pv_used` figure for the PV you're about to drain against the sum of `pv_free` across every *other* PV in the VG. If the other PVs don't have enough combined free space, `pvmove` will simply refuse to start (or stall partway) rather than doing anything destructive — the fix is the same `vgextend` with another disk that Part 2 used, not a data-loss risk.

> [!TIP]
> **Try it — build a three-way spread, then remove one PV out of three**
>
> `source_disk` has been sitting raw and unclaimed since Part 3 removed it — that's the disk this exercise reuses to reach three PVs, no new hardware needed.
>
> **1. Rejoin `source_disk` to the volume group as an ordinary third PV:**
> ```sh
> sudo pvcreate "$source_disk"
> sudo vgextend company_storage "$source_disk"
> ```
> ```text
>   Physical volume "/dev/vdc" successfully created.
>   Volume group "company_storage" successfully extended
> ```
> Same two commands as Part 2 — nothing about rejoining a previously-removed disk is different from adding a brand-new one.
>
> **2. Grow `shared_documents` by 600 MiB, restricted to `spare_disk`:**
> ```sh
> sudo lvextend -L +600M /dev/company_storage/shared_documents "$spare_disk"
> ```
> ```text
>   Size of logical volume company_storage/shared_documents changed from 350.00 MiB to 950.00 MiB.
> ```
> Naming a PV after the size argument restricts the *new* extents to that PV specifically — the same technique this playground's own setup script used back in Part 1 to force every extent onto one disk. Here it guarantees the growth lands on `spare_disk`, not wherever the default allocator would otherwise choose.
>
> **3. Grow it again by 300 MiB, this time restricted to `source_disk`:**
> ```sh
> sudo lvextend -L +300M /dev/company_storage/shared_documents "$source_disk"
> ```
> ```text
>   Size of logical volume company_storage/shared_documents changed from 950.00 MiB to 1250.00 MiB.
> ```
>
> **4. Confirm the extent list now spans all three PVs:**
> ```sh
> sudo lvs -o +devices
> ```
> ```text
>   LV                VG              Attr       LSize     Devices
>   shared_documents  company_storage -wi-ao---- 1250.00m  /dev/vdd(0),/dev/vde(0),/dev/vdc(0)
> ```
> Three comma-separated entries in one `Devices` cell — one LV, three PVs. This is the layout the earlier "one dying disk" scenario never showed you: `second_disk` (`/dev/vdd`) holds the original 350 MiB, `spare_disk` (`/dev/vde`) holds the 600 MiB from step 2, `source_disk` (`/dev/vdc`) holds the 300 MiB from step 3.
>
> **5. Remove `spare_disk` — the *middle* PV, not the one holding the least or the most data:**
> ```sh
> sudo pvmove "$spare_disk" "$source_disk"
> ```
> ```text
>   /dev/vde: Moved: 41.00%
>   /dev/vde: Moved: 100.00%
> ```
> Naming `source_disk` as the second argument tells `pvmove` exactly where to send the evacuated extents, instead of leaving the choice to the allocator — useful whenever you want to control which disk absorbs the load, not just that *some* disk does.
>
> **6. Confirm the extent list one more time:**
> ```sh
> sudo lvs -o +devices
> ```
> ```text
>   LV                VG              Attr       LSize     Devices
>   shared_documents  company_storage -wi-ao---- 1250.00m  /dev/vdd(0),/dev/vdc(0),/dev/vdc(75)
> ```
> `spare_disk` (`/dev/vde`) is gone from the list entirely. `source_disk` (`/dev/vdc`) now carries two separate ranges — its original 300 MiB starting at extent 0, plus the 600 MiB just migrated onto it starting right after, at extent 75 (300 MiB ÷ 4 MiB per extent) — which is exactly why the same PV can appear more than once in this column: each entry is one contiguous range, not one entry per disk.
>
> **7. Detach and wipe the now-empty PV, same as Part 3:**
> ```sh
> sudo vgreduce company_storage "$spare_disk"
> sudo pvremove "$spare_disk"
> ```
> ```text
>   Removed "/dev/vde" from volume group "company_storage"
>   Labels on physical volume "/dev/vde" successfully wiped.
> ```
>
> **8. Confirm the VG is back to two PVs and the LV is untouched:**
> ```sh
> sudo pvs
> sudo vgs
> ```
> ```text
>   PV        VG              Fmt  Attr PSize    PFree
>   /dev/vdd  company_storage lvm2 a--  1020.00m  670.00m
>   /dev/vdc  company_storage lvm2 a--  1020.00m  120.00m
>
>   VG               #PV #LV #SN Attr   VSize VFree
>   company_storage   2   1   0 wz--n- 1.99g 0.77g
> ```
> `#PV 2`, same as after Part 3 — but the disks making up the pair have changed (`second_disk` and `source_disk` now, not `second_disk` and `spare_disk`), and `shared_documents` is still 1250 MiB, still mounted, still readable the entire time. Removing one PV out of three worked exactly like removing one PV out of two — because it *is* the same operation.

## What `pvremove` doesn't do

`pvremove` only edits LVM's own metadata on that device. It does not tell the kernel the physical drive is about to be pulled, and it does not touch anything below the block-device layer — no spin-down, no bus reset, nothing hardware-facing. On this playground's virtual disks that gap doesn't matter: a virtio device has no motor to stop and no bus transaction to finish, so once `pvremove` completes there is nothing else to do here. On a real machine, skipping the hardware-facing step is how people get spurious I/O errors in `dmesg` or, on some older controllers, a hung kernel thread — not because data was lost, but because something still expected the device to be there.

A minimal checklist for a real disk, after `pvremove` reports success:

- **Confirm LVM is really done with it:** `sudo pvs` and `sudo lsblk` — the disk should show no `VG`, no `FSTYPE`, no `MOUNTPOINT`.
- **Flush pending writes system-wide:** `sync`. Cheap, and removes any doubt about buffered writes elsewhere on the system that have nothing to do with this disk but might still be in flight.
- **SATA/SAS disks:** offline it at the kernel level before touching it physically — `echo 1 | sudo tee /sys/block/<dev>/device/delete` — then confirm it disappeared from `lsblk` and check `dmesg` for a clean removal message, not an I/O error.
- **NVMe drives:** most support the same kind of hot-remove through `nvme` tooling or the PCIe slot's own `remove` sysfs attribute; check your drive and chassis support hot-removal before relying on it — if in doubt, a full shutdown is the safe fallback.
- **Hardware RAID / hot-swap bays:** the OS block layer isn't the authority here — use the controller's own utility (vendor-specific: `storcli`, `megacli`, and similar) to mark the slot ready-to-remove, usually surfaced as a drive-bay LED you wait for before pulling anything.

None of this is optional because LVM asked nicely — it's a different layer's job entirely, which is exactly why `pvremove` finishing without error is not, by itself, the same statement as "safe to unplug."

> [!WARNING]
> **Common pitfalls**
>
> - **Treating `pvremove` success as physical-removal clearance.** On real hardware, it isn't — see the checklist above. On this playground's virtual disks, it is, because there's no physical layer underneath to clear.
> - **Starting `pvmove` without checking free space on the *other* PVs first.** It fails safely rather than corrupting anything, but checking with `pvs -o pv_name,pv_used,pv_free` up front saves a wasted run on a large migration.
> - **Assuming the PV you're removing holds a clean, single range.** As step 6 above shows, one PV can appear more than once in `lvs -o +devices` if it has absorbed extents at different times. Read the whole `Devices` cell, not just the first entry.

> *Removing a PV is always the same three commands, no matter how many PVs the VG has or how an LV's extents are laid out across them — the only thing that changes is how much free space you need elsewhere first. Getting the LVM layer to zero on a device is necessary but not sufficient for pulling it out of a real machine; the hardware layer keeps its own separate bookkeeping.*

## Reference

- `man pvmove` — the optional destination-PV argument used in step 5 above, to direct evacuated extents to a specific disk instead of letting the allocator choose.
- `man lvextend` / `man lvcreate` — the trailing PV-list argument used in steps 2–3 to restrict new extents to a named disk.
- Your storage controller's or cloud provider's own documentation for hot-removal — there is no single Linux-wide command for "make this physical disk safe to pull"; SATA, NVMe, and hardware RAID each expose that differently.
