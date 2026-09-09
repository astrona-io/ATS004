# Removable Media & the FAT32 Filesystem

Every filesystem so far in this section — ext4, LUKS-wrapped ext4 — has been built for one thing: a Linux machine managing its own disks, with real Unix ownership and permission bits on every file. FAT32 breaks that assumption on purpose. It is the filesystem format almost every USB flash drive, SD card, and camera ships with, precisely because it is the one format Windows, macOS, and Linux can all read and write natively, with no extra drivers. That cross-platform reach comes from a design that predates Unix permissions entirely — there is no owner, no group, no mode bits stored on the filesystem at all.

## How this module is organised

1. **[Part 1 — What FAT32 Is & Creating One](./course-01-what-fat32-is-and-creating-one.md)** — why a 1977-era filesystem format is still the default for removable media, what it structurally lacks compared to ext4/XFS, and creating one with `mkfs.vfat`.
2. **[Part 2 — Mounting FAT32 & Its Unix-less Quirks](./course-02-mounting-fat32-quirks.md)** — supplying ownership at mount time with `uid=`/`gid=`/`umask=`, and the 4 GiB single-file size limit that silently ends a large copy partway through.

## Learning objectives

After this module you can:

- Explain why FAT32 has no Unix ownership or permission metadata, and why that makes it the universal choice for removable media.
- Create a FAT32 filesystem with `mkfs.vfat -F 32` and set its volume label with `fatlabel`.
- Mount a FAT32 filesystem with `uid=`, `gid=`, and `umask=` options, and explain why those options exist only because the filesystem itself has nothing to read ownership from.
- State FAT32's 4 GiB single-file size limit and recognize it as the cause of a large file copy failing partway through with no useful error.
- Say when FAT32 is the right choice (cross-platform removable media) and when it never is (a Linux root or data filesystem needing real permissions).

## Before you start

You should be comfortable creating and mounting an ext4 filesystem (Module 1) and reading `/etc/fstab` entries (Module 5) — this module contrasts FAT32 against both.

The linked lab gives you an Ubuntu server VM with one spare 1 GB disk, unformatted. `dosfstools` (which provides `mkfs.vfat` and `fatlabel`) is already installed. Run the command blocks in Parts 1–2 in that VM, or work directly in the lab's `terminal` machine when you reach the graded task.
