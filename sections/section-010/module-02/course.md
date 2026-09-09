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

## How this module is organised

1. **[Part 1 — Partition Tables: MBR vs GPT](./course-01-partition-tables-mbr-vs-gpt.md)** — what actually lives in each table format on-disk, why MBR has no redundancy and a hard capacity ceiling, and why GPT's dual-copy, CRC-checked design fixes both.
2. **[Part 2 — Tools, Alignment & the Kernel Re-read Problem](./course-02-tools-alignment-and-kernel-rescan.md)** — writing a table with `fdisk` and `parted`, why partitions start at sector 2048, and what "the kernel still uses the old table" actually means and how to fix it.

## Learning objectives

After this module you can:

- Explain what a partition table is and how MBR and GPT differ in partition count, capacity limit, and redundancy — and why GPT's redundancy is a structural design choice, not a feature bullet.
- Choose GPT over MBR for any modern disk and say why.
- Create a GPT label and an aligned partition with `parted` non-interactively, and describe the equivalent `fdisk` session.
- Explain write amplification and why partitions start at sector 2048 to avoid it.
- Recognise the "kernel still uses the old table" condition, explain what `BLKRRPART` does, and resolve it with `partprobe`.

## Before you start

You should have read the previous module or otherwise know what `lsblk` and `blkid` show, and be comfortable in a Linux shell with `sudo`.

The linked playground gives you an Ubuntu server VM with passwordless `sudo` and one spare 12 GB disk (commonly `/dev/vdb`) that has **no partition table** — its tables are cleared on every boot. Run the command blocks in Parts 1–2 in that VM after connecting with `astrona ssh astro-section-010-module-02-playground`. `fdisk`, `parted`, `sfdisk`, `partprobe`, and `wipefs` are already installed.
