# Backing Up & Cloning Storage Devices

Every other module in this section changes storage — formats it, encrypts it, repairs it, mounts it. This one protects it. Before you do something risky to a disk, or before you hand a laptop's drive to someone who needs the same data on new hardware, you need a way to copy an entire storage device or its files somewhere safe, and a way to prove afterward that the copy is actually good.

Two tools do this, at two different layers. `dd` copies raw bytes, with no idea what a file or a filesystem even is — the tool for an exact, whole-disk clone. `tar` copies files, through the filesystem, the way `cp` does — the tool for backing up data you plan to restore onto different-sized storage, or restore individual files from later. Knowing which one a task calls for, and verifying the result, is the actual skill.

## How this module is organised

1. **[Part 1 — Cloning a Disk with dd](./course-01-cloning-a-disk-with-dd.md)** — what `dd` actually copies, why swapping `if=` and `of=` is the most infamous data-loss command in Linux, and imaging a disk to a file and back.
2. **[Part 2 — File-Level Backups with tar, and Verifying Them](./course-02-tar-backups-and-verifying.md)** — archiving and restoring with `tar`, when it beats `dd`, and proving a backup is actually good with checksums.

## Learning objectives

After this module you can:

- Explain what `dd` copies (raw bytes) versus what a filesystem-aware tool copies (files), and pick the right one for a given backup task.
- Clone a whole disk to another disk of equal or greater size with `dd`, and state why direction (`if=`/`of=`) is the single most dangerous detail in the command.
- Image a disk to a file with `dd` and restore that image back to a disk.
- Create and restore a compressed file-level archive with `tar`, preserving ownership and permissions with `-p`.
- Verify a backup or clone is actually correct with `sha256sum` or `cmp`, instead of assuming the copy command succeeding means the data is good.

## Before you start

You should be comfortable identifying disks with `lsblk`/`blkid` (Module 1) and creating/mounting an ext4 filesystem (Module 1). Nothing else from this section is required.

The linked lab gives you an Ubuntu server VM with two spare 1 GB disks — one pre-formatted with sample data, one blank. Run the command blocks in Parts 1–2 in that VM, or work directly in the lab's `terminal` machine when you reach the graded task.
