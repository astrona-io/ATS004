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

## How this module is organised

1. **[Part 1 — Partition vs File & Creating the Partition](./course-01-partition-vs-file-and-creating-it.md)** — why a partition skips the filesystem-driver layer a swap file has, and carving one with `parted`.
2. **[Part 2 — Formatting, Priorities & Persistence](./course-02-formatting-priorities-persistence.md)** — `mkswap` + `swapon` on the partition, the priority-bucket mechanism behind `pri=`, and making both swap areas survive a reboot via `/etc/fstab`.

## Learning objectives

After this module you can:

- Explain why a swap partition avoids the filesystem-driver overhead a swap file has.
- Create a swap partition with `parted` + `mkswap` and activate it with `swapon`.
- Write `/etc/fstab` entries that bring swap areas back after a reboot, keyed by `UUID=`.
- Set swap priorities with `pri=` (on the command line and in `/etc/fstab`) and predict the fill order from the kernel's priority-bucket / round-robin mechanism.
- Apply an `/etc/fstab` swap change with `swapoff -a` / `swapon -a` and roll it back.

## Before you start

You need the previous module's material: what swap does, and `mkswap` / `swapon` / `swapoff` / `swapon --show` / `free`. Partitioning with `parted` (from the local-storage section) is assumed.

The linked playground gives you an Ubuntu server VM with 2 GB RAM, one spare 1 GB disk (commonly `/dev/vdb`, wiped raw each boot) to partition, and `/etc/fstab` pre-copied to `/etc/fstab.orig` so edits roll back with one command. Run the command blocks in both parts in that VM after `astrona ssh section-040-module-02-playground`.
