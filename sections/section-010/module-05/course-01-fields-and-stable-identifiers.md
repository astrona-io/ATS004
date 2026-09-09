# Part 1 — fstab Fields & Stable Identifiers

> Prerequisite: [Module landing page](./course.md). Next: [Part 2 — Options & Verifying Before You Trust It](./course-02-options-and-verifying.md).

A `mount` command lasts until reboot. To have a filesystem come back automatically every boot, you describe it in `/etc/fstab` — the filesystem table. This part covers the six fields of one entry, and why the very first field should almost never be a `/dev/` path.

## An entry, field by field

Here is one complete entry for a data disk:

```text
UUID=1b9e0c4a-3f2d-4a5b-8c0d-1e2f3a4b5c6d  /mnt/data1  ext4  defaults,nofail  0  2
```

The six whitespace-separated fields:

| # | Field | This example | Meaning |
| --- | --- | --- | --- |
| 1 | device | `UUID=1b9e...` | What to mount. `UUID=`, `LABEL=`, `PARTUUID=`, or a `/dev/...` path. For swap the field is still the device; for network mounts it is `host:/export` or `//host/share`. |
| 2 | mount point | `/mnt/data1` | Where to attach it. An absolute path, or `none` for swap. |
| 3 | type | `ext4` | Filesystem type: `ext4`, `xfs`, `vfat`, `nfs`, `swap`, or `auto` to let the kernel probe. |
| 4 | options | `defaults,nofail` | Comma-separated mount options (Part 2). |
| 5 | dump | `0` | Used by the old `dump` backup tool. Almost always `0`. |
| 6 | pass | `2` | `fsck` order at boot: `0` = never, `1` = root filesystem only, `2` = other local filesystems. Network and swap are `0`. |

At boot, systemd's fstab generator reads every line and turns it into a `.mount` unit (covered in full in Module 6) — `/etc/fstab` is a convenience front end over that generator, not something the kernel parses directly.

> [!TIP]
> **Try it — read the existing table**
>
> ```sh
> cat /etc/fstab
> findmnt --fstab
> findmnt /
> ```
>
> Expect something like:
>
> ```text
> UUID=abcd-1234  /  ext4  defaults  0  1
>
> TARGET SOURCE    FSTYPE OPTIONS
> /      UUID=abcd-1234 ext4  defaults
>
> TARGET SOURCE         FSTYPE OPTIONS
> /      /dev/vda1      ext4   rw,relatime
> ```
>
> The root entry uses `UUID=` and `pass` = `1` (root is checked first). `findmnt --fstab` shows what the file *says*; plain `findmnt /` shows what is *actually mounted* now — the same filesystem, resolved to its live device name.

## Why not `/dev/sdX`

Kernel device names are assigned in detection order. Add a disk, or boot with a USB stick plugged in, and today's `/dev/vdb` can be tomorrow's `/dev/vdc`. An fstab line naming `/dev/vdb` would then mount the wrong disk — or nothing.

Stable identifiers avoid this:

- **`UUID=`** — a random ID written into the filesystem at `mkfs` time. Unique, unchanging. The default choice.
- **`LABEL=`** — a human-set name. Convenient, but you must keep labels unique yourself.
- **`PARTUUID=`** — an ID on the *partition table* entry rather than the filesystem. Useful for filesystems that have no UUID, and for `root=` on the kernel command line.

`blkid` prints all of them.

> [!TIP]
> **Try it — add an entry keyed by UUID**
>
> ```sh
> sudo blkid /dev/vdb
> UUID=$(sudo blkid -s UUID -o value /dev/vdb)
> echo "UUID=$UUID  /mnt/data1  ext4  defaults,nofail  0  2" | sudo tee -a /etc/fstab
> sudo mkdir -p /mnt/data1
> sudo mount -a
> findmnt /mnt/data1
> ```
>
> Expect something like:
>
> ```text
> /dev/vdb: LABEL="DATA1" UUID="1b9e0c4a-..." TYPE="ext4"
>
> TARGET      SOURCE    FSTYPE OPTIONS
> /mnt/data1  /dev/vdb  ext4   rw,relatime,nofail
> ```
>
> `mount -a` mounts everything in `/etc/fstab` that is not already mounted. `findmnt` confirms `/mnt/data1` is now live, and the entry will be re-applied on every boot.

> *A device field in `/etc/fstab` is not "which disk" — it's "which disk, resolved how." `/dev/vdb` resolves by boot-time detection order; `UUID=` resolves by a value written once and never touched again. Only one of those is guaranteed to still mean the same disk next boot.*

## Reference

- `man 5 fstab` — the authoritative field-by-field reference, including the less common device forms (network shares, swap).
- `man 8 blkid` — printing `UUID=`/`LABEL=`/`PARTUUID=` for a device, used throughout this part.
