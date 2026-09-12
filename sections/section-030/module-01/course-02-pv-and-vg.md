# Part 2 — Physical Volumes & Volume Groups

> Prerequisite: [Part 1 — Why LVM & the Three-Layer Model](./course-01-why-lvm-and-the-stack.md). Next: [Part 3 — Logical Volumes](./course-03-logical-volumes.md).

Part 1 named the three layers and the extent-list model that ties them together. This part builds the bottom two: marking disks as usable by LVM, then pooling them into the extent pool an LV will draw from.

## Physical volumes

`pvcreate <device>...` writes a small LVM label and a metadata area at the **start** of each device — not a full-disk format. That metadata area is where LVM will later record VG membership and, once the device joins a VG, the extent-assignment lists for every LV that draws from it. The device must not hold data you want; `pvcreate` doesn't erase the rest of the disk, but it also doesn't check what's there beyond a signature scan, so running it against an in-use device corrupts that device's own filesystem header the same way `mkfs` would.

`pvs` gives a one-line-per-PV summary; `pvdisplay` gives the full detail, including the metadata area's own size and location.

> [!TIP]
> **Try it — see the raw disks, then initialise two as PVs**
>
> ```sh
> lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,SERIAL
> sudo pvs
> sudo pvcreate /dev/vdc /dev/vdd
> sudo pvs
> ```
>
> Expect something like (columns and exact sizes vary):
>
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
>
>   (first pvs: no output — nothing is a PV yet)
>
>   Physical volume "/dev/vdc" successfully created.
>   Physical volume "/dev/vdd" successfully created.
>
>   PV         VG Fmt  Attr PSize PFree
>   /dev/vdc      lvm2 ---  1.00g 1.00g
>   /dev/vdd      lvm2 ---  1.00g 1.00g
> ```
>
> `lsblk` shows the layout: `vda` is the OS disk (it has partitions and mount points), `vdb` is the tiny boot-config disk, and `vdc`/`vdd`/`vde` are the three empty 1 GB disks — no `FSTYPE`, no `MOUNTPOINT`, matched by the `SERIAL` column. After `pvcreate`, `/dev/vdc` and `/dev/vdd` show `Fmt = lvm2`. The `VG` column is blank because they are not in a volume group yet, and `PFree` equals `PSize` because none of their space is assigned — there is no extent list referencing them yet.

## Volume groups and physical extents

`vgcreate <name> <pv>...` welds PVs into one named pool. `<name>` is not a keyword — it's whatever you type there, invented on the spot (Part 1's note on names). Below, `company_storage` is that invented name; `/dev/vdc`/`/dev/vdd` are the real PVs from the previous section. `vgs` shows each VG's total and free size; `vgdisplay <name>` adds detail.

This is the step where the extent model from Part 1 becomes real: joining a VG is what divides a PV into **physical extents (PEs)**, 4 MiB blocks by default. Every allocation LVM makes from this point on — every `lvcreate`, every `lvextend` — is a whole number of these PEs, drawn from whichever PVs in the VG currently have free ones. A PV outside any VG has no extents yet; it's just a labeled disk waiting to be pooled.

> As an analogy: physical extents are Lego bricks of one size. The volume group is a bin of them; building a logical volume is snapping some bricks together. The analogy breaks down because LVM can also relocate individual "bricks" to a different disk later while the structure built from them stays assembled — `pvmove`, covered in the next module.

> [!TIP]
> **Try it — pool the PVs and read the extent size**
>
> ```sh
> sudo vgcreate company_storage /dev/vdc /dev/vdd
> sudo vgs
> sudo vgdisplay company_storage | grep -E 'VG Size|PE Size|Total PE|Free  PE'
> ```
>
> Expect something like:
>
> ```text
>   Volume group "company_storage" successfully created
>
>   VG               #PV #LV #SN Attr   VSize    VFree
>   company_storage   2   0   0 wz--n-    1.99g    1.99g
>
>   VG Size               1.99 GiB
>   PE Size               4.00 MiB
>   Total PE              510
>   Free  PE / Size       510 / 1.99 GiB
> ```
>
> `company_storage` reports the two 1 GB disks as one ~2 GiB pool. `PE Size` is the default 4 MiB, and `Total PE` (510 here) is how many 4 MiB blocks that pool contains — the currency every later allocation is measured in. `#LV 0` confirms nothing has claimed any of those extents yet.

> *`pvcreate` only ever touches the start of a device — a label and a metadata area. The extent pool doesn't exist until `vgcreate` divides the joined PVs into fixed-size PEs; that division is what Part 3's `lvcreate` draws from.*

## Reference

- `man pvcreate` — the `--metadatasize` and `--dataalignment` options, relevant when a PV sits on hardware with a specific I/O alignment requirement.
- `man vgcreate` — `-s`/`--physicalextentsize` to change the 4 MiB default; rarely needed, but worth knowing it's not fixed.
