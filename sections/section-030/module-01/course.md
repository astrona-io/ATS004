# LVM Fundamentals

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-030/module-01/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-030/module-01/playground
> astrona destroy section-030-module-01-playground
> ```

A plain partition is welded to one disk at a fixed size. When it fills up, growing it means copying everything to a bigger disk and swapping mount points — usually with downtime. The Logical Volume Manager (LVM) removes that rigidity by inserting an abstraction layer between physical disks and the filesystems the OS mounts, so volumes can grow, shrink, and move across disks while they are in use.

This module covers the three layers LVM stacks — physical volumes, volume groups, and logical volumes — the unit of space they trade in (the physical extent), and the commands to build each layer.

## Learning objectives

After this module you can:

- Explain the roles of a physical volume (PV), a volume group (VG), and a logical volume (LV), and how they stack.
- Initialise disks as PVs with `pvcreate` and inspect them with `pvs` / `pvdisplay`.
- Pool PVs into a VG with `vgcreate` and read its size and extent size with `vgs` / `vgdisplay`.
- Carve an LV from a VG with `lvcreate`, then format and mount it like a normal partition.
- Identify which physical disks an LV's extents currently live on.

## Before you start

You should know how to format and mount a filesystem (`mkfs.ext4`, `mount`, `df`) from the earlier sections and be comfortable with `sudo`.

The linked playground gives you an Ubuntu server VM with passwordless `sudo`, the `lvm2` toolset installed, and **three spare 1 GB disks** — `/dev/vdc`, `/dev/vdd`, `/dev/vde` (also reachable by their stable serial names `/dev/disk/by-id/virtio-s30m01-a`, `…-b`, `…-c`) — that carry no LVM metadata and no filesystem. They are wiped on every boot. Connect to the VM with `astrona ssh astro-section-030-module-01-playground`, then run the command blocks below there.

A quick note on the disk names before you touch anything: `/dev/vda` is the system disk with the OS on it, and `/dev/vdb` is a tiny (~366 KiB) read-only disk the platform uses for boot configuration — leave both alone. Only `vdc`, `vdd`, and `vde` are yours to experiment with. Always run `lsblk` first and match on the serial column, not on the letter.

## Why LVM exists

> As an analogy: a plain partitioned disk is a building with poured concrete interior walls — the floor plan is fixed. LVM is the same building fitted out with modular cubicle partitions: the same floor space, but you can move a wall next week without demolition. The analogy breaks down because LVM can also *add more floor space* by absorbing another disk, which no amount of moving walls in one building can do.

Concretely: with LVM you can start a database volume at 50 GB, and when it approaches full, add a new disk to the pool and grow the volume — and the filesystem on top of it — in a few seconds, with the database still running.

## The three layers

LVM stacks three layers, each built from the one below:

```text
  Logical Volumes    app_data (50G)   logs (10G)      <- format & mount these
  ------------------------------------------------
  Volume Group       data_pool  (one pool of extents)
  ------------------------------------------------
  Physical Volumes   /dev/vdc   /dev/vdd             <- initialised disks/partitions
```

- A **physical volume (PV)** is a whole disk or a partition that you have marked for LVM use.
- A **volume group (VG)** is one or more PVs pooled into a single space.
- A **logical volume (LV)** is a slice carved out of a VG. It appears as a block device you format and mount; it does not have to fit on any single physical disk.

## Physical volumes

`pvcreate <device>...` writes a small LVM label and metadata area to the start of each device, marking it as available to LVM. The device must not hold data you want — `pvcreate` does not format the whole disk, but the disk should be free.

`pvs` gives a one-line-per-PV summary; `pvdisplay` gives the full detail.

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
> `lsblk` shows the layout: `vda` is the OS disk (it has partitions and mount points), `vdb` is the tiny boot-config disk, and `vdc`/`vdd`/`vde` are the three empty 1 GB disks — no `FSTYPE`, no `MOUNTPOINT`, matched by the `SERIAL` column. After `pvcreate`, `/dev/vdc` and `/dev/vdd` show `Fmt = lvm2`. The `VG` column is blank because they are not in a volume group yet, and `PFree` equals `PSize` because none of their space is assigned.

## Volume groups and physical extents

`vgcreate <name> <pv>...` welds PVs into one named pool. `vgs` shows each VG's total and free size; `vgdisplay <name>` adds detail.

When a PV joins a VG, LVM divides it into equal blocks called **physical extents (PEs)**, 4 MiB each by default. Every allocation LVM makes from then on is a whole number of PEs.

> As an analogy: physical extents are Lego bricks of one size. The volume group is a bin of them; building a logical volume is snapping some bricks together. The analogy breaks down because LVM can also relocate individual "bricks" to a different disk later while the structure stays assembled — `pvmove` in the next module.

> [!TIP]
> **Try it — pool the PVs and read the extent size**
>
> ```sh
> sudo vgcreate vgdata /dev/vdc /dev/vdd
> sudo vgs
> sudo vgdisplay vgdata | grep -E 'VG Size|PE Size|Total PE|Free  PE'
> ```
>
> Expect something like:
>
> ```text
>   Volume group "vgdata" successfully created
>
>   VG     #PV #LV #SN Attr   VSize    VFree
>   vgdata   2   0   0 wz--n-    1.99g    1.99g
>
>   VG Size               1.99 GiB
>   PE Size               4.00 MiB
>   Total PE              510
>   Free  PE / Size       510 / 1.99 GiB
> ```
>
> `vgdata` reports the two 1 GB disks as one ~2 GiB pool. `PE Size` is the default 4 MiB, and `Total PE` (510 here) is how many 4 MiB blocks that pool contains — the currency every later allocation is measured in.

## Logical volumes

`lvcreate -n <name> -L <size> <vg>` grabs enough extents from the VG to satisfy `<size>` and links them into a block device at `/dev/<vg>/<name>` (also `/dev/mapper/<vg>-<name>`). `-n` sets the name; `-L` sets an absolute size (`-l` instead takes a count of extents or a percentage).

The resulting device is formatted and mounted exactly like a partition. Its extents may come from more than one PV, and nothing above the LV layer can tell.

> [!TIP]
> **Try it — carve, format, and mount an LV**
>
> ```sh
> sudo lvcreate -n applv -L 200M vgdata
> sudo lvs -o +devices
> sudo mkfs.ext4 /dev/vgdata/applv
> sudo mkdir -p /mnt/applv
> sudo mount /dev/vgdata/applv /mnt/applv
> df -h /mnt/applv
> ```
>
> Expect something like (middle `lvs` columns trimmed here for width):
>
> ```text
>   Logical volume "applv" created.
>
>   LV    VG     Attr       LSize   ... Devices
>   applv vgdata -wi-a----- 200.00m     /dev/vdc(0)
>
>   Filesystem                Size  Used Avail Use% Mounted on
>   /dev/mapper/vgdata-applv  172M   24K  158M   1% /mnt/applv
> ```
>
> `lvs -o +devices` shows the extents for `applv` came from `/dev/vdc` (a 200 MiB request fits on one disk). `/dev/vdc(0)` means "starting at physical extent 0 of that PV". After `mkfs.ext4` and `mount`, `df` shows an ordinary ext4 filesystem — the LVM layers underneath are invisible to it, and the reported size is a little under 200 MiB because the filesystem's own metadata takes a cut. Request a size larger than one disk and `Devices` would list both PVs.

> [!WARNING]
> **Common pitfalls**
>
> - **`pvcreate` on the wrong device.** Running it on a disk that holds a filesystem or the system disk (`/dev/vda` here) overwrites the start of that device. Confirm with `lsblk` and `blkid` first, and match on the disk's serial rather than its `vdX` letter — letters can shift between boots, serials do not. Same care as `mkfs`.
> - **Trying to format the volume group.** A VG is a pool, not a device. There is no `/dev/vgdata` to `mkfs`. You format the *logical volume* (`/dev/vgdata/applv`).
> - **Confusing the VG name with a path.** `vgcreate` and `lvcreate` take the VG *name* (`vgdata`); `mkfs`/`mount` take the LV *path* (`/dev/vgdata/applv`).
> - **Forgetting the filesystem step.** `lvcreate` gives you a raw block device. Until you `mkfs` it, there is nothing to mount.
> - **Expecting an LV to sit on one disk.** By default LVM allocates from wherever there are free extents; a large LV can span PVs. Use `lvs -o +devices` to see where it actually landed.
