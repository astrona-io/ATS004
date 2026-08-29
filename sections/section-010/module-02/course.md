# Splitting the Acre: Partitioning Raw Storage

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-010/module-02/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-010/module-02/playground
> astrona destroy section-010-module-02-playground
> ```

A raw disk is one continuous run of sectors. Before a filesystem goes on it, you almost always divide it into one or more **partitions**: numbered, fixed regions with a recorded start and end. Even a disk that will hold a single filesystem normally gets one partition first, because a partition gives the filesystem a defined boundary and lets tools reason about the disk's layout.

This chapter covers the two partition-table formats you will meet (MBR and GPT), the two tools you will use to write them (`fdisk` and `parted`), why partitions start where they do, and what to do when the kernel does not immediately notice a change you made.

## Learning objectives

After this module you can:

- Explain what a partition table is and how MBR and GPT differ in partition count, capacity limit, and redundancy.
- Choose GPT over MBR for any modern disk and say why.
- Create a GPT label and an aligned partition with `parted` non-interactively, and describe the equivalent `fdisk` session.
- Explain why partitions start at sector 2048 and check a partition's alignment.
- Recognise the "kernel still uses the old table" condition and resolve it with `partprobe`.

## Before you start

You should have read the previous module or otherwise know what `lsblk` and `blkid` show, and be comfortable in a Linux shell with `sudo`.

The linked playground gives you an Ubuntu server VM with passwordless `sudo` and one spare 12 GB disk (commonly `/dev/vdb`) that has **no partition table** — its tables are cleared on every boot. Run the command blocks below in that VM after connecting with `astrona ssh section-010-module-02-playground`. `fdisk`, `parted`, `sfdisk`, `partprobe`, and `wipefs` are already installed.

## What a partition is and why you draw one

A **partition** is a recorded region of a disk with a start sector, an end sector, and a number (`vdb1`, `vdb2`, …). The list of those regions lives in a small area at the front of the disk called the **partition table**.

Partitioning a disk before formatting it buys you three things: filesystems get explicit boundaries so they cannot overlap; the disk can hold several independent filesystems if you later want that; and standard tooling (bootloaders, `lsblk`, cloud imaging systems) expects a partition table and behaves predictably when it finds one.

> As an analogy: a partition table is the plot map filed with a county office. The land does not change, but the recorded boundaries let everyone agree where one lot ends and the next begins. The analogy breaks down because rewriting a partition table is instant and leaves the existing file data in place — unlike re-surveying real land.

## Partition table formats: MBR vs GPT

Two formats exist for that table.

**MBR (Master Boot Record)**, from 1983, stores the table in the first 512-byte sector of the disk. That tiny space forces two well-known limits:

- **Four primary partitions.** A fifth requires turning one primary slot into an *extended* partition that acts as a container for *logical* partitions — an awkard workaround.
- **A ~2.2 TB ceiling.** MBR addresses sectors with a 32-bit number; at 512 bytes per sector that caps the addressable space at 2^32 × 512 bytes ≈ 2.2 TB. Space beyond that on a larger disk is simply unreachable through MBR.

**GPT (GUID Partition Table)**, part of the UEFI specification, replaces MBR:

| Property | MBR | GPT |
| --- | --- | --- |
| Primary partitions | 4 (more via extended/logical) | 128 by default |
| Sector addressing | 32-bit (~2.2 TB max) | 64-bit (effectively unlimited) |
| Table redundancy | single copy | primary at the start, backup copy at the end |
| Partition/disk identity | none built in | every partition and disk has a globally unique GUID |

For any disk you provision today, use GPT. MBR is only relevant for very old systems that cannot boot from GPT.

> The playground's disk is 12 GB, so the 2.2 TB MBR ceiling cannot be demonstrated here — it only bites on disks larger than that. The partition-count and redundancy differences are structural and apply at any size.

## The tools: fdisk and parted

`fdisk` is an interactive, menu-driven editor. `sudo fdisk /dev/vdb` drops you into a prompt where single letters build the layout *in memory* until you write it:

- `p` — print the current table
- `g` — create a fresh GPT label (`o` creates a legacy MBR label)
- `n` — new partition (prompts for number, first sector, last sector or a `+size` like `+10G`)
- `d` — delete a partition
- `t` — change a partition's type code
- `w` — write the in-memory layout to disk and exit
- `q` — quit **without** writing; drafted changes are discarded

`parted` does the same job but takes its commands on the command line, which makes it scriptable. `sudo parted -s /dev/vdb mklabel gpt` writes a GPT label in one shot; `-s` means "script mode, do not ask questions".

A worked `fdisk` session to put one 10 GB partition on an empty GPT disk looks like this: run `sudo fdisk /dev/vdb`; press `g` to lay down a GPT label; press `n`, accept the default partition number `1`, accept the default first sector `2048`, and answer the last-sector prompt with `+10G`; press `p` to review the draft; press `w` to commit. Nothing touches the disk until that final `w`.

The `parted` equivalent is two commands and no prompts, which is what the checkpoint below runs.

> [!TIP]
> **Try it — create a GPT partition with parted**
>
> ```sh
> sudo fdisk -l /dev/vdb
> sudo parted -s /dev/vdb mklabel gpt
> sudo parted -s /dev/vdb mkpart data ext4 1MiB 10GiB
> lsblk /dev/vdb
> ```
>
> Expect something like:
>
> ```text
> Disk /dev/vdb: 12 GiB, 12884901888 bytes, 25165824 sectors
> Disklabel type: dos            (or: the command reports no partition table)
> ...
>
> NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS
> vdb    254:16   0  12G  0 disk
> └─vdb1 254:17   0  10G  0 part
> ```
>
> After the two `parted` commands the disk has a GPT label and one 10 GiB child partition `vdb1`, ready to be formatted with `mkfs.ext4` exactly as in the previous module. The `mkpart` argument `ext4` only sets a type hint; it does not create a filesystem.

## Why partitions start at sector 2048

Left to their defaults, `fdisk` and `parted` both start the first partition at sector 2048, one full mebibyte in (2048 × 512 bytes = 1,048,576 bytes). The reason is physical alignment.

Older drives used 512-byte physical sectors. Modern drives and SSDs use larger physical blocks — usually 4096 bytes — but still present 512-byte *logical* sectors to the OS for compatibility ("512e"). If a partition starts at a logical sector that is not a multiple of 8 (8 × 512 = 4096), every filesystem block straddles two physical blocks. A single 4 KiB write then forces the drive to read two physical blocks, modify parts of both, and write both back — **write amplification**, which can cut throughput substantially and wear an SSD faster.

Sector 2048 is a multiple of 8, so partitions and filesystem blocks line up with the physical 4 KiB blocks underneath. Accept the default unless you have a specific reason not to.

> [!TIP]
> **Try it — check partition alignment**
>
> ```sh
> sudo parted /dev/vdb align-check optimal 1
> sudo fdisk -l /dev/vdb
> ```
>
> Expect something like:
>
> ```text
> 1 aligned
>
> Device     Start      End  Sectors Size Type
> /dev/vdb1   2048 20973567 20971520  10G Linux filesystem
> ```
>
> `align-check optimal 1` reports partition 1 as `aligned`, and `fdisk -l` shows it starting at sector `2048` — the default the tools chose for you.

## When the kernel keeps the old partition table

When you change a partition table, the kernel has to reload its in-memory picture of the disk. It will refuse to do that while any partition on the disk is mounted or otherwise in use, to avoid corrupting a live filesystem. You then see a message like:

```text
Re-reading the partition table failed.: Device or resource busy.
The kernel still uses the old table.
```

Two ways out, no reboot needed:

1. Unmount every filesystem on the disk (and deactivate any LVM volume groups on it), then the write succeeds normally.
2. Ask the kernel to rescan with `partprobe`:

   ```sh
   sudo partprobe /dev/vdb
   ```

The same lag shows up harmlessly: delete a partition with `parted` or `fdisk`, and `lsblk` may still list the deleted child until a `partprobe` (or the tool's own end-of-session sync) refreshes the kernel's view.

> [!TIP]
> **Try it — force a partition-table rescan**
>
> ```sh
> sudo parted -s /dev/vdb rm 1
> lsblk /dev/vdb
> sudo partprobe /dev/vdb
> lsblk /dev/vdb
> ```
>
> Expect something like:
>
> ```text
> vdb    254:16   0  12G  0 disk
> └─vdb1 254:17   0  10G  0 part       <-- still listed right after rm
>
> vdb    254:16   0  12G  0 disk        <-- gone after partprobe
> ```
>
> `parted` removed the partition entry, but the kernel's device list lagged until `partprobe` told it to rescan. On a disk with a mounted partition, that rescan is exactly what the kernel declines to do automatically.

> [!WARNING]
> **Common pitfalls**
>
> - **Initialising a large disk with `o` (MBR).** On a disk larger than ~2.2 TB, MBR makes the space past that point unusable. Use `g` in `fdisk`, or `parted mklabel gpt`, for any modern disk.
> - **Overriding the default start sector.** Typing a custom first sector (an old habit from the sector-63 era) can misalign the partition and cause write amplification. Accept sector 2048.
> - **Editing the wrong disk.** `fdisk` and `parted` act on whatever device you name. Confirm with `lsblk` — size and mount point — before writing a label.
> - **Expecting `q` in `fdisk` to save.** `q` quits and discards; only `w` writes.
> - **Assuming `lsblk` is instantly right after a change.** The kernel's view can lag a partition edit. Run `sudo partprobe <disk>` if `lsblk` and reality disagree.
