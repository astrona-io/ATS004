# Backing Up & Cloning Storage Devices

Astronaut, most storage work changes a disk: you format it, encrypt it, repair it or mount it. This module protects a disk instead. Before you do something risky to a disk, or before you move a laptop's data to new hardware, you need a safe copy. You also need a way to prove afterwards that the copy is really good.

Two tools do this job, at two different layers. `dd` copies raw bytes and has no idea what a file or a filesystem is. It makes a copy of a cargo hold crate by crate, empty corners included: an exact, whole-disk clone. `tar` copies files through the filesystem, the way `cp` does. It packs chosen items into one shipping container that you can unpack on a different disk later. Knowing which tool a task needs, and checking the result, is the real skill.

## Learning objectives

After this module you can:

- Explain what `dd` copies (raw bytes) and what a filesystem-aware tool copies (files), and pick the right one for a backup task.
- Clone a whole disk to another disk of the same size or larger with `dd`, and explain why the direction (`if=` and `of=`) is the most dangerous detail in the command.
- Copy a disk to an image file with `dd`, and restore that image to a disk.
- Create and restore a compressed archive of files with `tar`, keeping owners and permissions with `-p`.
- Prove that a backup or clone is correct with `sha256sum` or `cmp`, instead of trusting that the copy command finished without an error.

## Before you start

This module has no playground. You read the two parts, then prove the skill in one graded mission.

### What you should already know

- **Finding disks.** You can list block devices with `lsblk` and read filesystem details with `blkid`.
- **Creating and mounting an ext4 filesystem.** You know `mkfs.ext4` and `mount`.

### The machine you will use

The mission machine is an Ubuntu 24.04 virtual machine with two spare 1 GB disks. One already holds a small ext4 filesystem with sample data; the other is blank. The examples in the parts use `/dev/vdb` and `/dev/vdc`; on a real machine, always confirm the names with `lsblk` first.

## The parts of this module

1. **[Cloning a Disk with dd](./course-01-cloning-a-disk-with-dd.md)**: what `dd` copies, why swapping `if=` and `of=` destroys data, and how to copy a disk to a file and back.
2. **[File-Level Backups with tar, and Verifying Them](./course-02-tar-backups-and-verifying.md)**: archiving and restoring with `tar`, when it beats `dd`, and proving a copy is good with checksums. Ends with your mission.
3. **[Wrap-Up: Mission Debrief](./course-03-wrap-up.md)**: what you learned, your mission, and a short self-check.
