# Part 1 — What FAT32 Is & Creating One

> Prerequisite: [Module landing page](./course.md). Next: [Part 2 — Mounting FAT32 & Its Unix-less Quirks](./course-02-mounting-fat32-quirks.md).

Every filesystem you've built so far in this section stores, alongside each file's data, a Unix owner, a group, and permission bits — that metadata is *why* `chmod` and `chown` work. This part covers a filesystem that was never designed to store any of that, why manufacturers ship removable media with it anyway, and how to create one.

## Why a decades-old format is still the default

FAT32 (File Allocation Table, 32-bit) traces back to MS-DOS. Its on-disk structure is a flat table mapping each file to a chain of storage blocks — no inodes, no journal, no concept of a file "owner" at all. That simplicity is exactly why every operating system still speaks it fluently: Windows, macOS, and Linux all include native FAT32 support with no extra drivers, which is not true of ext4 (Windows/macOS need third-party tools) or NTFS (Linux support is read-write but not default everywhere). A USB stick formatted ext4 works perfectly on Linux and is a mystery to a Windows laptop; a USB stick formatted FAT32 works everywhere. That's the entire reason camera manufacturers, USB drive vendors, and router firmware all default to it.

In Linux, the kernel driver for FAT32 is called **vfat** (*virtual FAT* — the driver that added long-filename support on top of the original 8.3-name FAT format). You'll see both names: FAT32 refers to the on-disk format, `vfat` is what shows up in `mount` output and `/etc/fstab` as the filesystem type.

> As an analogy: ext4 is a library with a card catalogue recording who checked out each book and when it's due back. FAT32 is a single shelf list — title and location, nothing else. The shelf list works in any building; the card catalogue only works in libraries with the same rules for who's allowed to check things out.

## Creating a FAT32 filesystem

`mkfs.vfat` builds a FAT-family filesystem. The FAT format actually has three generations — FAT12, FAT16, FAT32 — that differ in how large a volume they can address, and `mkfs.vfat` will pick FAT16 on a small enough device unless you're explicit. `-F 32` forces the FAT32 variant regardless of device size, which matters because some LFCS-style tasks and some real hardware (very small flash chips) would otherwise silently format as FAT16 — a different on-disk layout that behaves slightly differently under the hood, even though most day-to-day commands don't visibly care.

> [!TIP]
> **Try it — format the spare disk as FAT32**
>
> ```sh
> lsblk
> sudo mkfs.vfat -F 32 -n USBDATA /dev/vdb
> ```
>
> Expect something like:
>
> ```text
> mkfs.fat 4.2 (2021-01-31)
> ```
>
> `-n USBDATA` sets the volume label at format time, the FAT32 equivalent of `mkfs.ext4`'s label option. `mkfs.vfat` is deliberately quiet on success — no pass/fail report like `mkfs.ext4`'s block-group summary, because there's a lot less structure to build.

## Labeling after the fact

If you need to relabel a FAT32 filesystem without reformatting it, `fatlabel` does what `tune2fs -L` does for ext4 — except it's a separate tool, because FAT32 is a completely different on-disk format with its own utilities, not a `tune2fs` mode.

> [!TIP]
> **Try it — read and change the label**
>
> ```sh
> sudo fatlabel /dev/vdb
> sudo fatlabel /dev/vdb TRAVEL_DRIVE
> sudo fatlabel /dev/vdb
> ```
>
> Expect something like:
>
> ```text
> USBDATA
>
> TRAVEL_DRIVE
> ```
>
> Called with just a device, `fatlabel` prints the current label; called with a device and a new name, it writes it. `blkid /dev/vdb` would also show `LABEL="TRAVEL_DRIVE" TYPE="vfat"` — same identification pattern as every other filesystem type in this course, just naming a different `TYPE`.

> *FAT32 isn't a smaller or older version of ext4 — it's a different kind of filesystem entirely, one built with no concept of a file owner. Part 2 covers what that means the moment you try to mount one.*

## Reference

- `man 8 mkfs.fat` — every FAT-family option, including the FAT12/16/32 selection logic `-F` overrides.
- `man 8 fatlabel` — the FAT label tool used above.
