# Part 1 — Partition Tables: MBR vs GPT

> Prerequisite: [Module landing page](./course.md). Next: [Part 2 — Tools, Alignment & the Kernel Re-read Problem](./course-02-tools-alignment-and-kernel-rescan.md).

A raw disk is one continuous run of sectors. Before a filesystem goes on it, you almost always divide it into one or more **partitions**: numbered, fixed regions with a recorded start and end, listed in a small **partition table** at the front of the disk. This part covers what that table actually holds on-disk, and why the format you choose to write it in (MBR or GPT) matters far beyond "which one is newer."

## What a partition is and why you draw one

A **partition** is a recorded region of a disk with a start sector, an end sector, and a number (`vdb1`, `vdb2`, …).

Partitioning a disk before formatting it buys you three things: filesystems get explicit boundaries so they cannot overlap; the disk can hold several independent filesystems if you later want that; and standard tooling (bootloaders, `lsblk`, cloud imaging systems) expects a partition table and behaves predictably when it finds one.

> As an analogy: a partition table is the plot map filed with a county office. The land does not change, but the recorded boundaries let everyone agree where one lot ends and the next begins. The analogy breaks down because rewriting a partition table is instant and leaves the existing file data in place — unlike re-surveying real land.

## MBR: one sector, no safety net

**MBR (Master Boot Record)**, from 1983, packs the entire table into the disk's first 512-byte sector: 446 bytes of boot code, then exactly four 16-byte **partition entries**, then a 2-byte `0x55AA` signature that marks the sector as a valid boot record. That layout is the direct cause of MBR's two limits:

- **Four primary partitions.** There is physically room for four 16-byte entries and no more. A fifth partition requires turning one primary slot into an *extended* partition that acts as a container for *logical* partitions — a workaround bolted onto a format that was never designed to hold more than four.
- **A ~2.2 TB ceiling.** Each entry's start/length fields are 32-bit sector counts. At 512 bytes per sector, 2^32 sectors is the addressing limit: 2^32 × 512 bytes ≈ 2.2 TB. Space on a larger disk past that boundary has no sector number MBR can express, so it is simply unreachable.

The sharper cost of cramming everything into one sector: there is exactly **one copy**. A write that corrupts those 512 bytes — a bad sector, an interrupted write, stray bytes from another tool — takes the entire disk's layout with it. Nothing backs it up.

## GPT: a protective MBR, then two copies of the real table

**GPT (GUID Partition Table)**, part of the UEFI specification, fixes both problems by design, not by extension:

- **A "protective MBR" still sits in sector 0** — a single legacy-format partition entry marking the *whole disk* as type `0xEE`. Its only job is to make old MBR-only tools see "one giant already-used partition" and refuse to touch the disk, instead of reporting it as blank and offering to overwrite it.
- **The real table lives in two places**: a **primary GPT header + partition entry array** starting at LBA 1 (right after the protective MBR), and an identical **backup copy at the very end of the disk**. Each copy carries its own CRC32 checksum. If the primary header's checksum fails on read, GPT-aware tools fall back to the backup and can rewrite the primary from it — a corrupted primary is a repair, not a disaster, which MBR has no equivalent for.
- **64-bit sector addressing** removes the 2.2 TB ceiling in practice, and **128 partition entries by default** removes the four-slot limit without an extended-partition workaround.
- **Every partition and disk carries a GUID** — a random unique identifier baked into the format itself, which MBR has no field for at all.

| Property | MBR | GPT |
| --- | --- | --- |
| Partition entries | 4 (more via extended/logical) | 128 by default |
| Sector addressing | 32-bit (~2.2 TB max) | 64-bit (effectively unlimited) |
| Table redundancy | single copy, sector 0 only | primary at the start, backup at the end, both CRC32-checked |
| Partition/disk identity | none built in | every partition and disk has a GUID |

For any disk you provision today, use GPT. MBR is only relevant for very old systems that cannot boot from GPT.

> [!TIP]
> **Try it — look at both tables' footprint**
>
> ```sh
> sudo fdisk -l /dev/vdb
> sudo parted -s /dev/vdb mklabel gpt
> sudo sgdisk -p /dev/vdb 2>/dev/null || sudo parted -s /dev/vdb print
> ```
>
> Expect something like:
>
> ```text
> Disk /dev/vdb: 12 GiB, 12884901888 bytes, 25165824 sectors
> Disklabel type: dos            (or: the command reports no partition table)
>
> Model: Virtio Block Device
> Disk /dev/vdb: 12.9GB
> Partition Table: gpt
> ```
>
> The playground's disk is 12 GB, so the 2.2 TB MBR ceiling cannot be demonstrated directly — it only bites on disks larger than that. The partition-count and redundancy differences are structural and apply at any size, which is why `parted -s /dev/vdb mklabel gpt` is worth writing out of habit even on a small disk.

> *MBR has one table and hopes nothing corrupts it; GPT has two, checks both with a CRC, and can heal one from the other — the entire redundancy story in a single design choice.*

## Reference

- `man 8 fdisk` — the `-l` flag used above to list a disk's current label without opening the interactive editor.
- `man 8 sgdisk` — a scriptable GPT-specific tool; `sgdisk -p` prints the GUID table sgdisk-style, including both header checksums.
