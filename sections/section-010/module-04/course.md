# The Digital Auditor: Filesystem Maintenance, Labeling, and Tuning

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-010/module-04/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-010/module-04/playground
> astrona destroy section-010-module-04-playground
> ```

A filesystem is a database on disk: tables of file metadata, maps of which blocks are free, indexes from directory names to those records. A clean shutdown leaves that database consistent. A power cut, a controller glitch, or a failing sector mid-write can leave it inconsistent, and then you need tools to check it, repair it, and identify it reliably afterwards.

## How this module is organised

1. **[Part 1 — Filesystem Corruption & the fsck Repair Model](./course-01-fsck-repair-model.md)** — how a crash leaves a filesystem's structures disagreeing, what the superblock and journal actually store, and the one hard rule for running `fsck` safely.
2. **[Part 2 — Labels, UUIDs & Tuning Check Intervals](./course-02-labels-uuids-and-tuning.md)** — giving a filesystem a stable label and UUID so it always mounts as the right thing, and the `tune2fs` counters that schedule a periodic full check.

## Learning objectives

After this module you can:

- Explain what the superblock and the journal store and why journaling makes most crashes cheap to recover from.
- State the rule about never running `fsck` on a mounted filesystem, and say why it's a real data race, not a formality.
- Run `fsck` in read-only (`-n`) and automatic-repair (`-y`) modes and read its pass output.
- Set a filesystem label with `tune2fs -L` and read a filesystem's UUID with `blkid`.
- Mount a filesystem by `LABEL=` or `UUID=` instead of by `/dev/sdX`, and explain why that is safer in `/etc/fstab`.
- Schedule (and disable) a periodic full check with `tune2fs -c` / `-i`, independent of journal replay.

## Before you start

You should know how to create and mount an ext4 filesystem from the earlier modules and be comfortable with `sudo`.

The linked playground gives you an Ubuntu server VM with passwordless `sudo` and one spare 2 GB disk (commonly `/dev/vdb`) that already holds an **unmounted** ext4 filesystem, labelled `OLD_LABEL`, with a few sample files. Because it is unmounted, it is safe to run `fsck` against it. Run the command blocks in Parts 1–2 in that VM after connecting with `astrona ssh astro-section-010-module-04-playground`. `fsck`, `tune2fs`, `dumpe2fs`, and `blkid` are already installed.
