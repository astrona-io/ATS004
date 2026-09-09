# Part 2 — File-Level Backups with tar, and Verifying Them

> Prerequisite: [Part 1 — Cloning a Disk with dd](./course-01-cloning-a-disk-with-dd.md). Next: [Module landing page](./course.md).

`dd` copies bytes; `tar` copies files. That difference decides which one you reach for. A `dd` image of a 1 TB disk that's 5% full is still 1 TB — every unused block gets copied along with the real data. A `tar` archive of the same disk's files is roughly the size of the actual data, because `tar` walks the filesystem's directory tree and only ever touches real files, the same way `cp` or `ls -R` would. It's also filesystem-agnostic in the other direction: a `tar` archive restores onto a differently-sized disk, a different filesystem type, even a different Linux distribution, because it never cared about the source's block layout to begin with. `dd`'s exactness is `tar`'s flexibility, and neither is strictly better — they solve different problems.

## Creating and restoring an archive

```text
tar czf backup.tar.gz <path>      # create (c), gzip-compress (z), to this file (f)
tar tzf backup.tar.gz             # list contents without extracting (t)
tar xzf backup.tar.gz -C <dest>   # extract (x) into <dest>
```

> [!TIP]
> **Try it — back up and restore a directory**
>
> ```sh
> sudo tar czf /root/data-backup.tar.gz -C /mnt/data .
> tar tzf /root/data-backup.tar.gz | head -5
> sudo rm -rf /mnt/data/*
> sudo tar xzf /root/data-backup.tar.gz -C /mnt/data
> ls /mnt/data
> ```
>
> Expect something like:
>
> ```text
> ./
> ./report.txt
> ./notes/
> ./notes/todo.txt
>
> report.txt  notes
> ```
>
> `-C /mnt/data .` tells `tar` to change into that directory first and archive its contents as relative paths (`./report.txt`, not `/mnt/data/report.txt`) — the reason a `tar` archive restores cleanly into a different directory, or a different machine, without every path being wrong. `tzf` lists the table of contents so you can check what's actually in an archive before trusting it.

## Preserving ownership and permissions

By default `tar` (run as root, restoring as root) preserves ownership and permissions automatically — but the moment a non-root user, a different UID mapping, or certain archive formats are involved, add `-p` (`--preserve-permissions`) explicitly to make sure it's not left to default behavior. This matters most for a system backup you intend to restore onto a fresh machine: a config file restored `root:root 644` when it needs to be `www-data:www-data 640` is a silent, easy-to-miss failure.

## When to reach for tar instead of dd

- **Restoring onto different-sized or different-typed storage.** A `tar` archive doesn't care if the new disk is bigger, smaller (as long as it fits the actual data), or a different filesystem entirely. A `dd` image only restores onto a destination at least as large as the original, and reproduces the *exact same filesystem type* — no flexibility either way.
- **Restoring individual files.** `tar tzf` / `tar xzf path/to/one-file` pulls a single file back out. A `dd` image has no such concept — you'd need to loop-mount the whole image first.
- **Repeated, space-efficient backups.** `tar` only archives real files, so repeated backups of a mostly-unchanged filesystem stay small relative to the disk. (For genuinely incremental backups — only what changed since last time — the standard tool is `rsync`, not covered in depth here, but worth knowing it exists for that job.)

`dd` still wins when the goal is an exact duplicate regardless of content — cloning a boot disk with a bootloader and partition table intact, for instance, where `tar`'s file-level view has nothing to say about the bytes outside any filesystem.

## Verifying a backup is actually good

A copy command exiting with no error means the command ran — not that the data is correct. The only way to know a backup or clone actually matches its source is to check, and the tool is a checksum: a short fingerprint of the data such that any difference in the data produces a completely different fingerprint.

> [!TIP]
> **Try it — verify a disk clone matches its source**
>
> ```sh
> sudo sha256sum /dev/vdb /dev/vdc
> ```
>
> Expect something like:
>
> ```text
> 8f3b1c9e2a7d4f6b1e0c9a8d7b6e5f4a3c2b1a09e8d7c6b5a4f3e2d1c0b9a8f7  /dev/vdb
> 8f3b1c9e2a7d4f6b1e0c9a8d7b6e5f4a3c2b1a09e8d7c6b5a4f3e2d1c0b9a8f7  /dev/vdc
> ```
>
> Identical hashes mean identical bytes, end to end — the strongest possible confirmation that a `dd` clone or image genuinely matches its source. `cmp /dev/vdb /dev/vdc` does the same job for two block devices directly, and stops at the first differing byte if there is one, which is faster than a full checksum when you just need a yes/no answer. For a `tar` archive, the equivalent check is simpler: `tar tzf` catches a corrupted archive (`tar` will error partway through listing it), and spot-checking a few restored files' content is normal practice — a full checksum comparison only makes sense against an unpacked copy, not the archive itself.

> *A backup nobody has verified is a hope, not a backup. The five extra seconds a checksum takes is the entire difference between "I have a backup" and "I have a file I assume is a backup."*

> [!WARNING]
> **Common pitfalls**
>
> - **Swapping `if=` and `of=`.** The single most common way to destroy the wrong disk. Read the device names off `lsblk` immediately before running the command — every time, not just the first time.
> - **Forgetting `bs=`.** `dd`'s default 512-byte block size is real but almost never what you want — expect an order-of-magnitude slowdown on a large clone. Set `bs=4M` or larger.
> - **Cloning onto a smaller destination disk.** `dd` doesn't check sizes for you. Writing a larger source onto a smaller destination truncates silently — the copy stops when the destination runs out of space, with no error pointing at "wrong size," just a broken filesystem on the far end.
> - **Skipping `-p` on a `tar` restore where ownership matters.** Files restore with whatever ownership the extracting process defaults to unless permissions are explicitly preserved — easy to miss on a config or system backup.
> - **Trusting a backup that was never verified.** "The command didn't error" is not verification. Check a clone with `sha256sum`/`cmp`; check an archive with `tar tzf` and a spot-check restore.

## Reference

- `man tar` — the full flag set; `--exclude=` is worth knowing for skipping large, regenerable directories (caches, build output) from a backup.
- `man sha256sum` / `man cmp` — the two checksum-style verification tools referenced above.
