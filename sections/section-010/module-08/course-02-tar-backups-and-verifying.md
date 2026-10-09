# File-Level Backups with tar, and Verifying Them

`dd` copies bytes; `tar` copies files. That difference decides which one you use. A `dd` image of a 1 TB disk that is 5% full is still 1 TB, because every unused block is copied with the real data. A `tar` archive of the same disk's files is about the size of the real data. `tar` walks the filesystem's folders and only touches real files, the same way `cp` or `ls -R` would.

In space terms, `dd` copies the whole cargo hold, crate by crate, while `tar` packs chosen items into one shipping container. The container can be unpacked on a differently sized disk, a different filesystem type, even a different Linux distribution, because `tar` never cared about the source's block layout. Neither tool is better; they solve different problems.

## Creating and restoring an archive

Three `tar` commands cover almost every backup task: create, list and extract. This section shows the three, then runs them on a real folder.

### The three commands

```text
tar czf backup.tar.gz <path>      # create (c), gzip-compress (z), to this file (f)
tar tzf backup.tar.gz             # list contents without extracting (t)
tar xzf backup.tar.gz -C <dest>   # extract (x) into <dest>
```

### See it in action

On a machine with a filesystem mounted at `/mnt/data`, back up its contents, list the archive, empty the folder and restore it:

```sh
sudo tar czf /root/data-backup.tar.gz -C /mnt/data .
tar tzf /root/data-backup.tar.gz | head -5
sudo rm -rf /mnt/data/*
sudo tar xzf /root/data-backup.tar.gz -C /mnt/data
ls /mnt/data
```

Expect something like:

```text
./
./report.txt
./notes/
./notes/todo.txt

report.txt  notes
```

`-C /mnt/data .` tells `tar` to change into that folder first and store its contents with relative paths (`./report.txt`, not `/mnt/data/report.txt`). That is why the archive restores cleanly into a different folder or onto a different machine. `tzf` lists the table of contents, so you can check what is in an archive before you trust it.

## Keeping owners and permissions

When `root` creates and restores an archive, `tar` keeps owners and permissions by default. But as soon as a normal user, a different mapping of user IDs, or some archive formats are involved, add `-p` (`--preserve-permissions`) so you do not depend on the default.

This matters most for a system backup that you plan to restore on a fresh machine. A configuration file restored as `root:root 644` when it needs to be `www-data:www-data 640` is a silent failure that is easy to miss.

## When tar beats dd

The two tools overlap, so it helps to know the cases where `tar` is clearly the better choice, and the one case where `dd` still wins.

### Where tar is the better tool

- **Restoring onto storage of a different size or type.** A `tar` archive does not care if the new disk is bigger, smaller (as long as the real data fits) or uses another filesystem. A `dd` image only restores onto a disk at least as large as the original, and always brings back the exact same filesystem type.
- **Restoring single files.** `tar tzf` and `tar xzf <archive> path/to/one-file` pull out one file. A `dd` image has no such idea; you would need to mount the whole image first.
- **Repeated, small backups.** `tar` only stores real files, so repeated backups of a mostly unchanged filesystem stay small. For true incremental backups (only what changed since last time), the usual tool is `rsync`, which this module does not cover.

### Where dd still wins

`dd` wins when you need an exact copy whatever the content. Cloning a boot disk with its boot loader and partition table is the classic case. Those bytes sit outside any filesystem, so `tar`, which only sees files, cannot copy them.

## Proving a backup is good

A copy command that ends with no error only proves that the command ran. It does not prove the data is correct. This section shows how to check, using a checksum.

### A fingerprint of the data

A checksum is a short fingerprint of the data. Any change in the data, even one byte, gives a completely different fingerprint. So two identical checksums mean two identical copies.

### See it in action

After cloning `/dev/vdb` onto `/dev/vdc`, compare the checksums of the two disks:

```sh
sudo sha256sum /dev/vdb /dev/vdc
```

Expect something like:

```text
8f3b1c9e2a7d4f6b1e0c9a8d7b6e5f4a3c2b1a09e8d7c6b5a4f3e2d1c0b9a8f7  /dev/vdb
8f3b1c9e2a7d4f6b1e0c9a8d7b6e5f4a3c2b1a09e8d7c6b5a4f3e2d1c0b9a8f7  /dev/vdc
```

Your checksum will be a different string. What matters is that both lines show the same one. Identical checksums mean identical bytes from start to end, the strongest proof that a `dd` clone or image matches its source.

### Faster yes-or-no checks

`cmp /dev/vdb /dev/vdc` does the same job for two block devices directly. It stops at the first byte that differs, so it is faster than a full checksum when you only need a yes or no.

For a `tar` archive, the check is simpler. `tar tzf` catches a damaged archive, because `tar` stops with an error partway through the list. Spot-checking the content of a few restored files is normal practice. A full checksum comparison only makes sense against an unpacked copy, not against the archive itself.

## Common pitfalls

> [!WARNING]
> - **Skipping `-p` on a `tar` restore where owners matter.** Files come back with whatever owner the extracting process picks, unless you keep permissions on purpose. Easy to miss on a configuration or system backup.
> - **Trusting a backup you never checked.** "The command did not show an error" is not a check. Compare a clone with `sha256sum` or `cmp`; check an archive with `tar tzf` and a test restore.

> *A backup nobody has checked is a hope, not a backup. The few extra seconds a checksum takes are the whole difference between "I have a backup" and "I have a file I assume is a backup".*

## Your mission: Disk Cloning & Backup

You can now clone a disk with `dd` and prove the clone is exact. The mission asks you to clone a disk that holds data onto a blank disk, byte for byte, and check the result.

Start the mission and connect to its machine:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-010/module-08/labs/lab-01
astrona ssh ats-004-lab-018
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-08/labs/lab-01
```

When the mission is done, remove it:

```sh
astrona destroy ats-004-lab-018
```
