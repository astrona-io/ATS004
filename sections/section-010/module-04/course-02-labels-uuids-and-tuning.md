# Part 2 — Labels, UUIDs & Tuning Check Intervals

> Prerequisite: [Part 1 — Filesystem Corruption & the fsck Repair Model](./course-01-fsck-repair-model.md). Next: [Module landing page](./course.md).

Part 1 covered repairing a damaged filesystem. This part covers identifying one reliably afterwards — and the `tune2fs` knobs that decide how often a check happens automatically, without you running `fsck` by hand.

## Stable identifiers: labels and UUIDs

Kernel device names like `/dev/vdb` are assigned in detection order and are **not stable**. Add another disk, or boot with a USB drive plugged in, and yesterday's `/dev/vdb` might be today's `/dev/vdc`. An `/etc/fstab` line that mounts `/dev/vdb` would then mount the wrong disk.

Two stable identifiers solve this, and they live in different places for a reason:

- The **UUID**, a random 128-bit value written into the superblock (Part 1) at format time. Unique and unchanging for the life of the filesystem — it never depends on anything you do afterward.
- The **label**, a short human-chosen string, also stored in the superblock, but one you set and can change at will. Convenient, but you must keep them unique yourself; the filesystem does not enforce it.

`blkid` (*block ID*) reads filesystem headers; `blkid <device>` prints both the label and the UUID. `tune2fs -L <label> <device>` sets or changes the label directly in the superblock (ext filesystems only — XFS uses `xfs_admin -L`, a different tool for a different on-disk format). You can then `mount LABEL=<label> <dir>` or `mount UUID=<uuid> <dir>`, and in `/etc/fstab` the first field is normally `UUID=...` for exactly this reason. `findmnt <path>` (*find mount*) shows what is mounted at a path and which device the identifier resolved to.

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
> The label changed from `OLD_LABEL` to `DB_REPLICA`, and the mount succeeded without naming `/dev/vdb` directly — the UUID resolved to the right device no matter what kernel name it currently has, because that resolution reads the superblock, not the device path.

## Tuning check intervals

`tune2fs` also adjusts when the system forces a check, via two independent counters it stores in the same superblock: `-c N` schedules a check after every `N` mounts; `-i <time>` schedules one after a calendar interval like `2m` (two months). Either counter firing forces a full `fsck` on the *next* boot, regardless of whether the journal thinks everything is clean — this is a periodic structural audit, not a crash-recovery mechanism, which is why it's independent of Part 1's journal replay. Setting `-c 0 -i 0` disables both, which is common on servers that rely on the journal and external monitoring instead of a scheduled full check that would extend a reboot's downtime unpredictably.

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
> - **Running `fsck` on a mounted filesystem.** Covered in Part 1 — the fastest way to destroy a filesystem. Always unmount first; for `/`, use rescue media or a boot-time check.
> - **`tune2fs` on a non-ext filesystem.** `tune2fs` only handles ext2/3/4 superblocks. On XFS it fails; use `xfs_admin` (for example `xfs_admin -L LABEL /dev/vdb`). Check the type with `blkid` first.
> - **Mounting by `/dev/sdX` in `/etc/fstab`.** Device names can change between boots. Use `UUID=` (or `LABEL=` if you manage labels carefully) so the right filesystem always mounts.
> - **Assuming missing files after a repair are gone.** `fsck` moves recovered fragments into `lost+found` at the root of the filesystem, named by inode number. Look there before concluding data was lost.

> *UUID and label both live in the same superblock Part 1 described — one is generated once and never changes, the other you set yourself and can break by duplicating it. That's the whole reason `/etc/fstab` defaults to UUID.*

## Reference

- `man 8 blkid` — the `-s`/`-o` flags used above to extract just one field instead of the full line.
- `man 8 tune2fs` — every superblock field `-c`/`-i`/`-L` touch, and the ext-specific feature flags Part 1's `-l` output listed.
