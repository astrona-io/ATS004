# Removable Media & the FAT32 Filesystem

Astronaut, every cargo hold you have built so far keeps a crew roster on each item. An ext4 filesystem stores an owner, a group and permission bits for every file, and that is why `chmod` and `chown` work. FAT32 breaks that habit on purpose.

FAT32 is the format almost every USB flash drive, SD card and camera ships with. It is the one format that Windows, macOS and Linux can all read and write with no extra drivers. That reach comes from a design older than Unix permissions: FAT32 stores no owner, no group and no permission bits at all. Think of it as a simple shelf list that works on every ship in the galaxy, but has no space to write down who owns each crate.

## Learning objectives

After this module you can:

- Explain why FAT32 has no Unix owner or permission data, and why that makes it the usual choice for removable media.
- Create a FAT32 filesystem with `mkfs.vfat -F 32` and set its volume label with `fatlabel`.
- Mount a FAT32 filesystem with the `uid=`, `gid=` and `umask=` options, and explain why those options exist: the filesystem has no ownership of its own to read.
- State the FAT32 limit of 4 GiB per file, and recognise it as the reason a large copy fails partway through.
- Say when FAT32 is the right choice (removable media shared between operating systems) and when it never is (a Linux system or data disk that needs real permissions).

## Before you start

This module is short and has no playground. You read the two parts, then prove the skill in one graded mission.

### What you should already know

- **Creating and mounting an ext4 filesystem.** You know `lsblk`, `mkfs.ext4` and `mount`, and that a filesystem is the shelving system you build inside an empty cargo hold.
- **Reading `/etc/fstab` entries.** You know that the filesystem type and the mount options sit in their own columns.

### The machine you will use

The mission machine is an Ubuntu 24.04 virtual machine with one spare 1 GB disk, not yet formatted. `dosfstools`, the package that provides `mkfs.vfat` and `fatlabel`, is already installed. The examples in the parts use `/dev/vdb` for the spare disk; on a real machine, always confirm the name with `lsblk` first.

## The parts of this module

1. **[What FAT32 Is & Creating One](./course-01-what-fat32-is-and-creating-one.md)**: why a format from the MS-DOS days is still the default for removable media, what it lacks compared to ext4, and how to create one with `mkfs.vfat`.
2. **[Mounting FAT32 & Its Unix-less Quirks](./course-02-mounting-fat32-quirks.md)**: giving the files an owner at mount time with `uid=`, `gid=` and `umask=`, and the 4 GiB file size limit. Ends with your mission.
3. **[Wrap-Up: Mission Debrief](./course-03-wrap-up.md)**: what you learned, your mission, and a short self-check.
