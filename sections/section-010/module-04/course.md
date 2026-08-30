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

This chapter covers the structures a filesystem keeps (the superblock and the journal), how to run a consistency check safely with `fsck`, and how to give a filesystem a stable label and UUID so it always mounts as the right thing.

## Learning objectives

After this module you can:

- Explain what the superblock and the journal store and why journaling makes most crashes cheap to recover from.
- State the rule about never running `fsck` on a mounted filesystem, and say why.
- Run `fsck` in read-only (`-n`) and automatic-repair (`-y`) modes and read its pass output.
- Set a filesystem label with `tune2fs -L` and read a filesystem's UUID with `blkid`.
- Mount a filesystem by `LABEL=` or `UUID=` instead of by `/dev/sdX`, and explain why that is safer in `/etc/fstab`.

## Before you start

You should know how to create and mount an ext4 filesystem from the earlier modules and be comfortable with `sudo`.

The linked playground gives you an Ubuntu server VM with passwordless `sudo` and one spare 2 GB disk (commonly `/dev/vdb`) that already holds an **unmounted** ext4 filesystem, labelled `OLD_LABEL`, with a few sample files. Because it is unmounted, it is safe to run `fsck` against it. Run the command blocks below in that VM after connecting with `astrona ssh astro-section-010-module-04-playground`. `fsck`, `tune2fs`, `dumpe2fs`, and `blkid` are already installed.

## Filesystems as databases, and how they get damaged

Every write you do is several coordinated changes: update the file's metadata record, mark data blocks as used, update the directory index, adjust the free-space count. If the machine dies between those changes, the on-disk structures disagree with each other — a directory entry pointing at a metadata record that was never written, blocks marked used that no file claims, and so on.

The tool that walks the whole structure and reconciles it is **`fsck`** (filesystem consistency check). When it finds a fragment of file data that has lost its directory entry, it does not throw it away; it links it into a directory called **`lost+found`** at the root of that filesystem, named by number, so you can inspect it later.

> As an analogy: the filesystem is a library and its card catalogue. A crash is a gust of wind that scatters some cards. `fsck` is the archivist who goes shelf by shelf, matches books to cards, shreds cards for books that are not there, and puts unlabelled loose pages in a box at the front desk (`lost+found`). The analogy breaks down because `fsck` works from redundant on-disk bookkeeping, not guesswork, and on a journaling filesystem it usually has almost nothing to do.

## The superblock and the journal

At a fixed spot near the start of an ext4 filesystem sits the **superblock**: the master record holding total block and inode counts, the free counts, the filesystem UUID and label, feature flags, and a "clean / not clean" state bit. It is important enough that `mkfs` writes backup copies at intervals across the disk; if the primary is damaged, tools can be pointed at a backup.

The **journal** is a small circular log. Before changing its main tables, ext4 writes a description of the intended change to the journal, then applies it. After a crash, mount replays completed journal entries and discards incomplete ones — a few seconds of work instead of a full scan. This is why `fsck` rarely runs at boot on a modern system: the journal has already handled the common case, and `fsck` is reserved for deeper damage.

`tune2fs` (*tune ext2/3/4 filesystem*) reads and adjusts ext-filesystem parameters that live in the superblock. `tune2fs -l <device>` prints the whole superblock in readable form.

> [!TIP]
> **Try it — read the superblock**
>
> ```sh
> sudo tune2fs -l /dev/vdb | grep -Ei 'volume name|state|mount count|UUID|features'
> ```
>
> Expect something like:
>
> ```text
> Filesystem volume name:   OLD_LABEL
> Filesystem UUID:          3f2b1c9a-7d6e-4a5b-8c0d-1e2f3a4b5c6d
> Filesystem features:      has_journal ext_attr resize_inode dir_index filetype extent 64bit flex_bg ...
> Filesystem state:         clean
> Mount count:              0
> Maximum mount count:      -1
> ```
>
> `has_journal` in the feature list confirms this is a journaling filesystem. `state: clean` means it was unmounted properly. `Maximum mount count: -1` means no automatic check is scheduled by mount count.

## Running fsck safely

The one hard rule: **never run `fsck` on a mounted filesystem.** A mounted filesystem has the kernel caching and flushing changes to the same sectors `fsck` wants to read and rewrite, assuming it has them to itself. The two writing at once corrupts the filesystem. Unmount first; for the root filesystem, that means booting from rescue media or using a boot-time check.

`fsck` is a wrapper that calls the right checker for the filesystem type (`e2fsck` for ext4). Its main modes:

- `sudo fsck /dev/vdb` — interactive; stops at each problem and asks.
- `sudo fsck -y /dev/vdb` — answers "yes" to every repair; used in unattended boot scripts.
- `sudo fsck -n /dev/vdb` — read-only; reports problems, changes nothing. Safe to run any time the filesystem is unmounted.

> [!TIP]
> **Try it — a read-only check**
>
> ```sh
> sudo fsck -n /dev/vdb
> ```
>
> Expect something like:
>
> ```text
> fsck from util-linux 2.39.3
> e2fsck 1.47.0 (5-Feb-2023)
> Pass 1: Checking inodes, blocks, and sizes
> Pass 2: Checking directory structure
> Pass 3: Checking directory connectivity
> Pass 4: Checking reference counts
> Pass 5: Checking group summary information
> OLD_LABEL: clean, 13/131072 files, 26156/524288 blocks
> ```
>
> The five passes check different parts of the structure; a healthy filesystem reports `clean` with file and block counts. If you run the same command while the disk is mounted, `e2fsck` warns `WARNING!!! ... filesystem is mounted` and asks you to confirm — the correct answer is no.

## Stable identifiers: labels and UUIDs

Kernel device names like `/dev/vdb` are assigned in detection order and are **not stable**. Add another disk, or boot with a USB drive plugged in, and yesterday's `/dev/vdb` might be today's `/dev/vdc`. An `/etc/fstab` line that mounts `/dev/vdb` would then mount the wrong disk.

Two stable identifiers solve this:

- The **UUID**, a random 128-bit value written into the superblock at format time. Unique and unchanging for the life of the filesystem.
- The **label**, a short human-chosen string. Convenient but you must keep them unique yourself.

`blkid` (*block ID*) reads filesystem headers; `blkid <device>` prints both the label and the UUID. `tune2fs -L <label> <device>` sets or changes the label (for ext filesystems only — XFS uses `xfs_admin -L`). You can then `mount LABEL=<label> <dir>` or `mount UUID=<uuid> <dir>`, and in `/etc/fstab` the first field is normally `UUID=...` for exactly this reason. `findmnt <path>` (*find mount*) shows what is mounted at a path and which device the identifier resolved to.

> [!TIP]
> **Try it — relabel, then mount by identifier**
>
> ```sh
> sudo tune2fs -L "DB_REPLICA" /dev/vdb
> sudo blkid /dev/vdb
> sudo mkdir -p /mnt/db-data
> sudo mount UUID="$(sudo blkid -s UUID -o value /dev/vdb)" /mnt/db-data
> findmnt /mnt/db-data
> sudo umount /mnt/db-data
> ```
>
> Expect something like:
>
> ```text
> /dev/vdb: LABEL="DB_REPLICA" UUID="3f2b1c9a-7d6e-4a5b-8c0d-1e2f3a4b5c6d" BLOCK_SIZE="4096" TYPE="ext4"
>
> TARGET     SOURCE   FSTYPE OPTIONS
> /mnt/db-data /dev/vdb ext4  rw,relatime
> ```
>
> The label changed from `OLD_LABEL` to `DB_REPLICA`, and the mount succeeded without naming `/dev/vdb` directly — the UUID resolved to the right device no matter what kernel name it currently has.

## Tuning check intervals

`tune2fs` also adjusts when the system forces a check. `-c N` schedules a check after every `N` mounts; `-i <time>` schedules one after an interval like `2m` (two months). Setting `-c 0 -i 0` disables both, which is common on servers that rely on the journal and monitoring instead.

> [!TIP]
> **Try it — set and confirm a mount-count check**
>
> ```sh
> sudo tune2fs -c 20 /dev/vdb
> sudo tune2fs -l /dev/vdb | grep -Ei 'mount count'
> ```
>
> Expect something like:
>
> ```text
> Setting maximal mount count to 20
>
> Mount count:              0
> Maximum mount count:      20
> ```
>
> `Maximum mount count` is now 20, so the 20th mount will trigger an automatic `fsck`. Re-running with `sudo tune2fs -c 0 /dev/vdb` sets it back to disabled.

> [!WARNING]
> **Common pitfalls**
>
> - **Running `fsck` on a mounted filesystem.** This is the fastest way to destroy a filesystem. Always unmount first; for `/`, use rescue media or a boot-time check. `fsck -n` on an unmounted device is the safe way to look without touching.
> - **`tune2fs` on a non-ext filesystem.** `tune2fs` only handles ext2/3/4. On XFS it fails; use `xfs_admin` (for example `xfs_admin -L LABEL /dev/vdb`). Check the type with `blkid` first.
> - **Mounting by `/dev/sdX` in `/etc/fstab`.** Device names can change between boots. Use `UUID=` (or `LABEL=` if you manage labels carefully) so the right filesystem always mounts.
> - **Assuming missing files after a repair are gone.** `fsck` moves recovered fragments into `lost+found` at the root of the filesystem, named by inode number. Look there before concluding data was lost.
