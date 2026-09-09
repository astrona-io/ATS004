# Part 2 — Mounting FAT32 & Its Unix-less Quirks

> Prerequisite: [Part 1 — What FAT32 Is & Creating One](./course-01-what-fat32-is-and-creating-one.md). Next: [Module landing page](./course.md).

Part 1 established that FAT32 stores no owner, group, or permission bits — only a filename and a chain of blocks. This part covers the consequence: mounting one plain, with no options, produces a filesystem every file on which appears to belong to `root`, unwritable by anyone else. Fixing that, and FAT32's other structural limit, is what this part covers.

## Ownership that doesn't exist on disk

When you `mount` an ext4 filesystem, the kernel reads each file's owner and permissions from that file's inode — the filesystem already recorded them at write time. FAT32 has no inode, no owner field, nothing to read. So the kernel's `vfat` driver has to be *told* what ownership to report for every file, as **mount options**, applied uniformly to the whole filesystem:

- **`uid=<N>`** — the numeric user ID every file should appear owned by.
- **`gid=<N>`** — the numeric group ID every file should appear owned by.
- **`umask=<mode>`** — the permission bits to *clear*, same meaning as a shell umask, applied to every file on mount rather than at each file's creation time (there's no per-file mode to set, since none is stored).

Mount a FAT32 filesystem without any of these and the kernel falls back to `uid=0,gid=0` — every file shows up owned by `root`, and a normal user's write attempts fail with "Permission denied" even though nothing on the actual medium ever recorded a permission.

> [!TIP]
> **Try it — mount plain, then compare with options**
>
> ```sh
> sudo mkdir -p /mnt/usbdata
> sudo mount /dev/vdb /mnt/usbdata
> ls -ld /mnt/usbdata
> touch /mnt/usbdata/test.txt
> sudo umount /mnt/usbdata
> sudo mount -o uid=$(id -u),gid=$(id -g),umask=022 /dev/vdb /mnt/usbdata
> ls -ld /mnt/usbdata
> touch /mnt/usbdata/test.txt && echo "write ok"
> ```
>
> Expect something like:
>
> ```text
> drwxr-xr-x 2 root root 16384 ... /mnt/usbdata
> touch: cannot touch '/mnt/usbdata/test.txt': Permission denied
>
> drwxr-xr-x 2 ubuntu ubuntu 16384 ... /mnt/usbdata
> write ok
> ```
>
> Same device, same data — the only thing that changed between the two mounts is which ownership the kernel was told to *report*. `id -u` / `id -g` substitute the current shell user's numeric IDs directly into the mount options, which is the normal way to mount removable media as "yours."

## The 4 GiB file that won't copy

FAT32 records each file's size in a 32-bit field, which tops out at 4,294,967,295 bytes — just under 4 GiB. This isn't a soft limit or a performance recommendation; it's the largest number the on-disk format is physically able to store for one file's size. Try to copy anything bigger — a Linux ISO, a VM disk image, a video export — and the copy runs for a while, silently succeeds right up to the boundary, then fails with a generic disk-full-style error even on a mostly-empty drive, because the *filesystem's format*, not the available space, is what stopped it.

> [!TIP]
> **Try it — hit the limit on purpose**
>
> ```sh
> df -h /mnt/usbdata
> fallocate -l 4200M /mnt/usbdata/toobig.bin
> ```
>
> Expect something like:
>
> ```text
> Filesystem      Size  Used Avail Use% Mounted on
> /dev/vdb        974M   16K  974M   1% /mnt/usbdata
>
> fallocate: fallocate failed: File too large
> ```
>
> The disk in this lab is only ~1 GB, so the failure here is obviously space — but the same "File too large" class of error appears on a mostly-empty multi-terabyte FAT32 drive the moment a single file crosses 4 GiB, which is the case worth remembering. **exFAT** is the modern Microsoft-designed successor built to remove this limit (and still carries no Unix permissions either) — it's not covered hands-on here, but it's the format to reach for when you need cross-platform compatibility *and* files bigger than 4 GiB.

## Where FAT32 belongs

FAT32 is the right call for exactly one job: removable media that needs to work unmodified on Windows, macOS, and Linux alike — a USB installer, a camera card, a firmware-update drive. It is never the right call for a Linux system's root filesystem or any data volume that needs real Unix ownership, multiple users with different access levels, or files anywhere near 4 GiB — that's ext4 or XFS territory, covered earlier in this section.

> [!WARNING]
> **Common pitfalls**
>
> - **Forgetting `-F 32` on a small device.** `mkfs.vfat` may pick FAT16 instead, a different on-disk layout with its own (smaller) size ceiling. Always pass `-F 32` explicitly when FAT32 is what's required.
> - **Mounting without `uid=`/`gid=`.** Every file appears owned by `root`; a normal user's writes fail with "Permission denied" even though nothing was ever actually restricted on the medium.
> - **Running `chmod` or `chown` on a mounted FAT32 file expecting it to persist.** There's no permission bit on the filesystem to change — the command either errors or silently no-ops depending on mount options. Ownership on FAT32 is a mount-time setting for the *whole filesystem*, not a per-file one.
> - **Copying a near-4GB file without checking first.** A copy that runs for minutes before failing wastes real time. `ls -lh` the source file and compare against 4 GiB before starting a long copy onto FAT32 media.
> - **Assuming FAT32 is fine for a data disk with multiple Linux users.** With no real ownership model, every user sees every file as whatever the mount's `uid=`/`gid=` says — there's no way to separate access between users on the same FAT32 volume the way ext4/XFS permissions do.

> *Every FAT32 quirk in this part traces back to the same root cause Part 1 named: the filesystem itself stores no owner, no permission bits, and only a 32-bit size field — everything here is a consequence of that, not a separate list of rules to memorize.*

## Reference

- `man 8 mount` — the `fat`/`vfat` filesystem-specific options section, including `uid=`, `gid=`, `umask=`, `dmask=`, `fmask=`.
- `man 8 mkfs.fat` — the on-disk size limits per FAT variant (FAT12/16/32) referenced above.
