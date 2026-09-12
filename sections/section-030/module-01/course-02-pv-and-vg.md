# Part 2 — Physical Volumes & Volume Groups

> Prerequisite: [Part 1 — Why LVM & the Three-Layer Model](./course-01-why-lvm-and-the-stack.md). Next: [Part 3 — Logical Volumes](./course-03-logical-volumes.md).

Part 1 named the three layers and the extent-list model that ties them together. This part builds the bottom two: marking disks as usable by LVM, then pooling them into the extent pool an LV will draw from.

## Physical volumes

`pvcreate <device>...` writes a small LVM label and a metadata area at the **start** of each device — not a full-disk format. That metadata area is where LVM will later record VG membership and, once the device joins a VG, the extent-assignment lists for every LV that draws from it. The device must not hold data you want; `pvcreate` doesn't erase the rest of the disk, but it also doesn't check what's there beyond a signature scan, so running it against an in-use device corrupts that device's own filesystem header the same way `mkfs` would.

`pvs` gives a one-line-per-PV summary; `pvdisplay` gives the full detail, including the metadata area's own size and location.

> [!TIP]
> **Try it — see the raw disks, then initialise two as PVs**
>
> Run each line one at a time and compare your output to what follows it — that's the only way to tell which line produced which result.
>
> **1. Look at every disk attached to the machine, before touching LVM at all:**
> ```sh
> lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,SERIAL
> ```
> ```text
>   NAME     SIZE TYPE MOUNTPOINT SERIAL
>   vda       25G disk
>   ├─vda1    24G part /
>   ├─vda15   99M part /boot/efi
>   └─vda16  923M part /boot
>   vdb      366K disk
>   vdc        1G disk            s30m01-a
>   vdd        1G disk            s30m01-b
>   vde        1G disk            s30m01-c
> ```
> `vda` is the OS disk — it has partitions and a `MOUNTPOINT`, so it's already in use; never point LVM at it. `vdb` is a tiny 366K boot-config disk, also not a candidate. `vdc`, `vdd`, and `vde` are the three empty 1 GB disks this lab gives you to practice on: no `FSTYPE`, no `MOUNTPOINT`, each identified by a `SERIAL` so you can tell them apart even if the `vdX` letters shift on a later boot.
>
> **2. Confirm none of them are PVs yet:**
> ```sh
> sudo pvs
> ```
> ```text
> (no output)
> ```
> An empty result is the expected result here — `pvs` only lists disks that have already been initialised as physical volumes, and you haven't run `pvcreate` yet.
>
> **3. Initialise two of the three spare disks as PVs:**
> ```sh
> sudo pvcreate /dev/vdc /dev/vdd
> ```
> ```text
>   Physical volume "/dev/vdc" successfully created.
>   Physical volume "/dev/vdd" successfully created.
> ```
> One confirmation line per disk you named. `/dev/vde` was left alone on purpose — it stays a plain, uninitialised disk for now.
>
> **4. Run `pvs` again to see the two new PVs:**
> ```sh
> sudo pvs
> ```
> ```text
>   PV         VG Fmt  Attr PSize PFree
>   /dev/vdc      lvm2 ---  1.00g 1.00g
>   /dev/vdd      lvm2 ---  1.00g 1.00g
> ```
> Compare this to step 2's empty result — that's the whole effect of `pvcreate`. `Fmt = lvm2` confirms the label was written. The `VG` column is blank because these PVs aren't in a volume group yet — that's the next step. `PFree` equals `PSize` because none of their space is assigned to anything — there is no extent list referencing them yet. `/dev/vde` doesn't appear at all, because it was never handed to `pvcreate`.

## Volume groups and physical extents

`vgcreate <name> <pv>...` welds PVs into one named pool. `<name>` is not a keyword — it's whatever you type there, invented on the spot (Part 1's note on names). Below, `company_storage` is that invented name; `/dev/vdc`/`/dev/vdd` are the real PVs from the previous section. `vgs` shows each VG's total and free size; `vgdisplay <name>` adds detail.

This is the step where the extent model from Part 1 becomes real: joining a VG is what divides a PV into **physical extents (PEs)**, 4 MiB blocks by default. Every allocation LVM makes from this point on — every `lvcreate`, every `lvextend` — is a whole number of these PEs, drawn from whichever PVs in the VG currently have free ones. A PV outside any VG has no extents yet; it's just a labeled disk waiting to be pooled.

> As an analogy: physical extents are Lego bricks of one size. The volume group is a bin of them; building a logical volume is snapping some bricks together. The analogy breaks down because LVM can also relocate individual "bricks" to a different disk later while the structure built from them stays assembled — `pvmove`, covered in the next module.

> [!TIP]
> **Try it — pool the PVs and read the extent size**
>
> **1. Create the volume group, naming it and listing the PVs it should pool:**
> ```sh
> sudo vgcreate company_storage /dev/vdc /dev/vdd
> ```
> ```text
>   Volume group "company_storage" successfully created
> ```
> `company_storage` is the name being invented right here — LVM has no prior idea what it means, it just records it. From this point on, every other command in this walkthrough refers back to this same name.
>
> **2. List volume groups to see the new pool:**
> ```sh
> sudo vgs
> ```
> ```text
>   VG               #PV #LV #SN Attr   VSize    VFree
>   company_storage   2   0   0 wz--n-    1.99g    1.99g
> ```
> `#PV 2` — the two disks you named are now pooled under this one VG. `#LV 0` — nothing has claimed any space from the pool yet; that's Part 3. `VSize`/`VFree` are equal because the pool is still entirely unused, and read as roughly the sum of the two 1 GB disks (a little under 2 GiB after LVM's own bookkeeping overhead).
>
> **3. Ask for the extent-size detail, filtered to the four lines that matter:**
> ```sh
> sudo vgdisplay company_storage | grep -E 'VG Size|PE Size|Total PE|Free  PE'
> ```
> ```text
>   VG Size               1.99 GiB
>   PE Size               4.00 MiB
>   Total PE              510
>   Free  PE / Size       510 / 1.99 GiB
> ```
> `PE Size` is the default 4 MiB chunk size introduced in Part 1. `Total PE` (510 here) is how many of those 4 MiB chunks the whole pool contains — the currency every later allocation is measured in. `Free PE` still equals `Total PE`, confirming (from a different angle than step 2's `VFree`) that nothing has been carved out yet.

> *`pvcreate` only ever touches the start of a device — a label and a metadata area. The extent pool doesn't exist until `vgcreate` divides the joined PVs into fixed-size PEs; that division is what Part 3's `lvcreate` draws from.*

## Reference

- `man pvcreate` — the `--metadatasize` and `--dataalignment` options, relevant when a PV sits on hardware with a specific I/O alignment requirement.
- `man vgcreate` — `-s`/`--physicalextentsize` to change the 4 MiB default; rarely needed, but worth knowing it's not fixed.
