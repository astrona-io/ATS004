# Part 1 — Cloning a Disk with dd

> Prerequisite: [Module landing page](./course.md). Next: [Part 2 — File-Level Backups with tar, and Verifying Them](./course-02-tar-backups-and-verifying.md).

`dd` (the name is historical — think "data duplicator", not the honest but ridiculed original expansion) copies raw bytes from one place to another, a block at a time. It does not know what a partition table is, what a filesystem is, or what a file is. That ignorance is exactly what makes it the right tool for a whole-disk clone: it doesn't need to understand the source's structure to reproduce it perfectly, byte for byte — partition table, filesystem metadata, every file, and every byte of unused free space along with it.

## The command, and what each part does

```text
dd if=<source> of=<destination> bs=<block size> status=progress
```

- **`if=`** (*input file*) — what to read from. Almost always a block device (`/dev/vdb`) for a disk clone, or an image file when restoring.
- **`of=`** (*output file*) — what to write to. A block device to clone onto, or a file to image into.
- **`bs=`** — how many bytes to read/write per chunk. The default is 512 bytes — historically accurate, practically terrible; at that size `dd` spends almost all its time on per-chunk overhead instead of moving data. `bs=4M` or `bs=64M` gets close to the disk's real throughput. Bigger isn't free either: a very large block size wastes memory on partial reads/writes at the end of a device that isn't an exact multiple of it. `4M`–`64M` is the practical range for a whole-disk clone.
- **`status=progress`** — prints a running byte count while it works. Without it, `dd` runs completely silent until it finishes, which on a large disk looks indistinguishable from a hung command.

## Cloning a whole disk

Clone `/dev/vdb` onto `/dev/vdc` — both the same size — and the destination ends up an exact duplicate: same partition table, same filesystems, same files, same UUID.

> [!TIP]
> **Try it — clone a disk**
>
> ```sh
> lsblk
> sudo dd if=/dev/vdb of=/dev/vdc bs=4M status=progress
> ```
>
> Expect something like:
>
> ```text
> NAME MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
> vda  253:0    0   15G  0 disk
> vdb  253:1    0    1G  0 disk
> vdc  253:2    0    1G  0 disk
>
> 1048576000 bytes (1.0 GB, 1000 MiB) copied, 4 s, 250 MB/s
> 250+0 records in
> 250+0 records out
> 1048576000 bytes (1.0 GB, 1000 MiB) copied, 4.19286 s, 250 MB/s
> ```
>
> `lsblk` first, always — confirming both device names and that `vdc` is the disk you actually mean to overwrite, before `dd` ever runs. `status=progress` prints the running total as it copies; the final three lines are `dd`'s own summary once it's done.

## The one warning that matters more than anything else in this module

`dd` has no confirmation prompt. No "are you sure". No undo. It does exactly what `if=` and `of=` say, immediately, and a destination that already had data on it is gone the instant the first block is written — not moved to trash, not recoverable with `fsck`, just overwritten. Getting `if=` and `of=` backwards, or targeting the wrong device because you trusted memory instead of `lsblk` output, is infamous enough in Linux folklore to have its own name: **"dd, the disk destroyer"** — every experienced admin either has a story about this or knows someone who does.

There is no clever flag that makes this safe. The only real protection is procedural:

- Run `lsblk` or `blkid` **immediately before** the command, in the same terminal, and read the device names off that output — not from memory, not from a note you made ten minutes ago.
- Say the direction out loud (or in a comment) before running it: "*from* vdb *to* vdc" — `if=` is the disk you're reading, `of=` is the disk about to be overwritten.
- Always include `status=progress`. A `dd` that should finish in five seconds and is still running after fifty means something is wrong — a much bigger destination device than expected, usually — and you want that visible immediately, not discovered after it finishes.

## Imaging a disk to a file, and restoring it

`of=` doesn't have to be a device — it can be a plain file, which turns a live disk into a portable backup image you can store elsewhere, restore later, or restore onto different hardware entirely.

> [!TIP]
> **Try it — image a disk, then restore it**
>
> ```sh
> sudo dd if=/dev/vdb of=/root/vdb-backup.img bs=4M status=progress
> ls -lh /root/vdb-backup.img
>
> # ...later, onto a fresh disk...
> sudo dd if=/root/vdb-backup.img of=/dev/vdc bs=4M status=progress
> ```
>
> Expect something like:
>
> ```text
> 1048576000 bytes (1.0 GB, 1000 MiB) copied, 4 s, 250 MB/s
> -rw-r--r-- 1 root root 1000M ... /root/vdb-backup.img
>
> 1048576000 bytes (1.0 GB, 1000 MiB) copied, 4 s, 250 MB/s
> ```
>
> The image file is exactly the size of the source disk, whether or not that space held real data — `dd` copied every block, used and unused alike. That's the tradeoff for imaging being an exact, no-questions-asked duplicate: no compression, no awareness of "empty" versus "used" space, unless you pipe through a compressor yourself (`dd ... | gzip > image.img.gz`, not covered here).

> *`dd` doesn't know what a file is — that's the whole point. It reproduces a disk exactly because it never has to understand it, and it destroys a disk exactly as fast, for exactly the same reason.*

## Reference

- `man dd` — every block-size and conversion option; `conv=sync,noerror` is worth knowing for cloning a disk with bad sectors, not covered here.
- `man lsblk` — the command to run, without exception, before every `dd` that targets a device.
