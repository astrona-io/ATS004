# Permanent Swap Partitions & Priority Scheduling

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-040/module-02/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-040/module-02/playground
> astrona destroy section-040-module-02-playground
> ```

A swap file is convenient but every page it handles passes through the filesystem driver (ext4, XFS) on its way to disk. A dedicated swap partition skips that layer: the kernel writes memory pages straight to the partition's raw blocks. For a machine's baseline swap you use a partition (or an LVM volume); a swap file is the fast add-on.

This module covers creating a swap partition, making swap persistent through `/etc/fstab`, and — when a machine has more than one swap area — using priorities so the kernel prefers the fast one.

## Learning objectives

After this module you can:

- Explain why a swap partition avoids the overhead a swap file has.
- Create a swap partition with `parted` + `mkswap` and activate it with `swapon`.
- Write `/etc/fstab` entries that bring swap areas back after a reboot, keyed by `UUID=`.
- Set swap priorities with `pri=` (on the command line and in `/etc/fstab`) and predict the fill order.
- Apply an `/etc/fstab` swap change with `swapoff -a` / `swapon -a` and roll it back.

## Before you start

You need the previous module's material: what swap does, and `mkswap` / `swapon` / `swapoff` / `swapon --show` / `free`. Partitioning with `parted` (from the local-storage section) is assumed.

The linked playground gives you an Ubuntu server VM with 2 GB RAM, one spare 1 GB disk (commonly `/dev/vdb`, wiped raw each boot) to partition, and `/etc/fstab` pre-copied to `/etc/fstab.orig` so edits roll back with one command. Run the command blocks below in that VM after `astrona ssh section-040-module-02-playground`.

## Partition vs file

> As an analogy: a swap file is a drawer inside a shared filing cabinet — you reach it through the cabinet's mechanism. A swap partition is a chute in the floor that drops straight to the basement. Fewer moving parts in the path. The analogy breaks down because the real difference is modest on SSDs; the filesystem overhead of a swap file matters most on slow spinning disks and heavily loaded systems.

A swap partition is any block device set aside for swap: a physical partition like `/dev/vdb1`, or an LVM logical volume like `/dev/mapper/vg-swap`. You do **not** put a filesystem on it — `mkswap` writes a swap header directly onto the device.

## Creating the partition

Give the spare disk a partition table and one partition spanning it, typed for swap. `parted`'s `linux-swap` filesystem keyword sets the correct partition type; it does not write a filesystem.

> [!TIP]
> **Try it — carve a swap partition**
>
> ```sh
> lsblk /dev/vdb
> sudo parted -s /dev/vdb mklabel gpt
> sudo parted -s /dev/vdb mkpart swap linux-swap 1MiB 100%
> sudo partprobe /dev/vdb
> lsblk /dev/vdb
> ```
>
> Expect something like:
>
> ```text
> vdb    254:16   0   1G  0 disk
>
> vdb    254:16   0   1G  0 disk
> └─vdb1 254:17   01022M  0 part
> ```
>
> `/dev/vdb1` now exists, sized to the whole disk. It has a partition type of "Linux swap" but no header yet — `mkswap` adds that next.

## Formatting and activating

`mkswap <device>` writes the swap signature and a UUID onto the partition. `swapon <device>` activates it. Because there is no filesystem in the path, reads and writes go to the raw blocks.

> [!TIP]
> **Try it — make it swap and turn it on**
>
> ```sh
> sudo mkswap /dev/vdb1
> sudo swapon /dev/vdb1
> swapon --show
> ```
>
> Expect something like:
>
> ```text
> Setting up swapspace version 1, size = 1022 MiB
> no label, UUID=7c2e...9a
>
> NAME      TYPE      SIZE USED PRIO
> /dev/vdb1 partition 1022M   0B   -2
> ```
>
> `swapon --show` lists `/dev/vdb1` with `TYPE partition` (a swap file shows `TYPE file`). `PRIO -2` was assigned automatically — the next section sets it on purpose.

## Priorities: preferring the fast area

A machine can have several swap areas active at once. By default the kernel gives each an automatically decreasing negative priority and, for areas of *equal* priority, spreads writes across them. If one area is a fast NVMe partition and another is a slow file on a spinning disk, equal treatment drags the fast one down to the slow one's speed.

The `pri=` value fixes this. User-set priorities run 0–32767; **higher wins**. The kernel fills the highest-priority area completely before it writes a single page to the next one down. So you give the fast device a high number and the slow fallback a low one.

To see this you need a second area. Create a small swap file the same way as the previous module — `fallocate`, `chmod 600`, `mkswap` — then activate both with explicit priorities.

> [!TIP]
> **Try it — two areas, explicit fill order**
>
> ```sh
> sudo fallocate -l 256M /swapfile
> sudo chmod 600 /swapfile
> sudo mkswap /swapfile
> sudo swapoff -a
> sudo swapon -p 10 /dev/vdb1
> sudo swapon -p 5 /swapfile
> swapon --show
> ```
>
> Expect something like:
>
> ```text
> NAME      TYPE      SIZE USED PRIO
> /dev/vdb1 partition 1022M   0B   10
> /swapfile file      256M    0B    5
> ```
>
> The `PRIO` column shows `10` for the partition and `5` for the file. Under memory pressure the kernel would fill `/dev/vdb1` entirely before touching `/swapfile` — the slow fallback only comes into play in a real emergency.

## Making it persistent

`swapon` activations are lost on reboot. `/etc/fstab` restores them. A swap line has six fields:

```text
UUID=7c2e...9a   none   swap   sw,pri=10   0   0
/swapfile        none   swap   sw,pri=5    0   0
```

- **device** — use `UUID=` for a partition (stable across disk reordering), found with `blkid`; a swap file is named by its path.
- **mount point** — `none`; swap is not in the directory tree.
- **type** — `swap`.
- **options** — `sw` (the conventional placeholder for "swap defaults") plus `pri=` for priority.
- **dump / pass** — `0` and `0`; neither backup nor `fsck` applies to swap.

Apply changes without rebooting by deactivating all swap and reactivating from the file.

> [!TIP]
> **Try it — write fstab entries and apply them**
>
> ```sh
> sudo blkid /dev/vdb1
> echo "UUID=$(sudo blkid -s UUID -o value /dev/vdb1)  none  swap  sw,pri=10  0  0" | sudo tee -a /etc/fstab
> echo "/swapfile  none  swap  sw,pri=5  0  0" | sudo tee -a /etc/fstab
> sudo swapoff -a
> sudo swapon -a
> swapon --show
> ```
>
> Expect something like:
>
> ```text
> NAME      TYPE      SIZE USED PRIO
> /dev/vdb1 partition 1022M   0B   10
> /swapfile file      256M    0B    5
> ```
>
> `swapon -a` read both lines from `/etc/fstab` and brought the areas up with the priorities you wrote. This configuration now survives a reboot. To undo the edits: `sudo cp /etc/fstab.orig /etc/fstab`.

> [!WARNING]
> **Common pitfalls**
>
> - **Putting a filesystem on a swap partition.** Do not run `mkfs.ext4` on it. `mkswap` is the only formatting a swap device needs; a filesystem there just wastes the `mkswap` step and confuses `blkid`.
> - **Naming a swap partition by `/dev/vdb1` in fstab.** Kernel device names can change between boots; the wrong device could be activated as swap. Use `UUID=` from `blkid`.
> - **Relying on the default with mixed-speed swap.** Equal (default) priorities make the kernel stripe writes across a fast and a slow area together. Set `pri=` so the fast one fills first.
> - **Assuming `pri=` on the command line persists.** `swapon -p 10 ...` lasts until reboot only. The priority must be in the `/etc/fstab` options column to stick.
> - **Editing `/etc/fstab` with no backup.** A malformed swap line makes `swapon -a` error (boot usually still continues, unlike a bad filesystem line). Keep a copy — the playground's is `/etc/fstab.orig` — and re-run `swapon -a` after editing to catch mistakes now rather than at the next reboot.
