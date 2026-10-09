# fstab Fields and Stable Identifiers

A `mount` command lasts only until the next reboot. Mounting is docking a cargo hold (a filesystem) to a hatch in the ship's one corridor of directories, and a reboot is landing and launching again: only what is written in the logbook comes back. That logbook is `/etc/fstab`, the filesystem table.

In this part you read one entry field by field. Then you learn why the first field should almost never be a `/dev/` path, and you add a working entry of your own.

## An entry, field by field

Each line in `/etc/fstab` describes one filesystem to mount at every boot. Start with one real line, then look at what each of its six fields does.

### One complete entry

Here is one complete entry for a data disk:

```text
UUID=1b9e0c4a-3f2d-4a5b-8c0d-1e2f3a4b5c6d  /mnt/data1  ext4  defaults,nofail  0  2
```

The line has six fields, split by spaces or tabs:

| # | Field | This example | Meaning |
| --- | --- | --- | --- |
| 1 | device | `UUID=1b9e...` | What to mount. `UUID=`, `LABEL=`, `PARTUUID=`, or a `/dev/...` path. For swap the field is still the device; for network mounts it is `host:/export` or `//host/share`. |
| 2 | mount point | `/mnt/data1` | Where to attach it. An absolute path, or `none` for swap. |
| 3 | type | `ext4` | Filesystem type: `ext4`, `xfs`, `vfat`, `nfs`, `swap`, or `auto` to let the kernel probe. |
| 4 | options | `defaults,nofail` | Comma-separated mount options. |
| 5 | dump | `0` | Used by the old `dump` backup tool. Almost always `0`. |
| 6 | pass | `2` | `fsck` order at boot: `0` = never, `1` = root filesystem only, `2` = other local filesystems. Network and swap are `0`. |

The `pass` field talks to `fsck`, the filesystem check. Think of `fsck` as the repair crew that walks the shelves and fixes broken tags before the hold is opened.

### Who reads the file

The kernel never reads `/etc/fstab` itself. At boot, systemd (the ship's duty officer, which starts every system in the right order) runs its fstab generator. The generator reads every line and turns it into a `.mount` unit: a duty order to dock one hold. systemd then carries out those orders, and the kernel does the actual mounting. So `/etc/fstab` is an easy front end for systemd's mount units.

When you run `sudo mount -a` by hand, a different program reads the file: the `mount` command. It tries every line that is not already mounted.

### See it in your playground

Read the table your training ship already has. Compare what the file says with what is mounted right now:

<!-- astrona:playground:renew -->

```sh
cat /etc/fstab
findmnt --fstab
findmnt /
```

Expect something like:

```text
UUID=abcd-1234  /  ext4  defaults  0  1

TARGET SOURCE    FSTYPE OPTIONS
/      UUID=abcd-1234 ext4  defaults

TARGET SOURCE         FSTYPE OPTIONS
/      /dev/vda1      ext4   rw,relatime
```

This is a short example. Your playground shows its own identifier for the root filesystem, and its file may list more lines.

The root entry uses `UUID=` and `pass` = `1`, because root is checked first. `findmnt --fstab` shows what the file *says*. Plain `findmnt /` shows what is *actually mounted* now: the same filesystem, shown by its live device name.

## Why not `/dev/sdX`

A device path like `/dev/vdb` looks like a fixed address, but it is not. This section explains why, and which identifiers to use instead.

### Device names move

The kernel (the ship's core) gives out device names in the order it finds the disks. Add a disk, or boot with a USB stick plugged in, and today's `/dev/vdb` can be tomorrow's `/dev/vdc`. An fstab line that names `/dev/vdb` would then mount the wrong disk, or nothing at all.

### Stable identifiers

A stable identifier is written into the disk itself, so it stays the same however the kernel numbers the disks. Think of a UUID as the hold's serial number and a label as its painted name:

- **`UUID=`**: a UUID (Universally Unique Identifier) is a random ID that `mkfs` writes into the filesystem when it builds it. It is unique and never changes. This is the default choice.
- **`LABEL=`**: a name that a person sets. It is easy to read, but you must keep labels unique yourself.
- **`PARTUUID=`**: an ID on the partition table entry, not on the filesystem. A partition table is the deck plan that lists the rooms in a hold. This ID is useful for filesystems that have no UUID, and for `root=` on the kernel command line.

`blkid` prints all of them.

### See it in your playground

Your playground has two spare disks with an ext4 filesystem on each, labelled `DATA1` and `DATA2`. Check with `sudo blkid` that `/dev/vdb` is the one labelled `DATA1`. Then add an entry keyed by its UUID and mount it:

```sh
sudo blkid /dev/vdb
UUID=$(sudo blkid -s UUID -o value /dev/vdb)
echo "UUID=$UUID  /mnt/data1  ext4  defaults,nofail  0  2" | sudo tee -a /etc/fstab
sudo mkdir -p /mnt/data1
sudo mount -a
findmnt /mnt/data1
```

Expect something like this (the UUID is shortened):

```text
/dev/vdb: LABEL="DATA1" UUID="1b9e0c4a-..." TYPE="ext4"

TARGET      SOURCE    FSTYPE OPTIONS
/mnt/data1  /dev/vdb  ext4   rw,relatime,nofail
```

`mount -a` mounts everything in `/etc/fstab` that is not already mounted. `findmnt` confirms that `/mnt/data1` is now live. systemd will dock it again on every boot, because the entry is now in the logbook.

## Common pitfalls

> [!WARNING]
> - **Naming devices by `/dev/sdX` or `/dev/vdX`.** These names can change between boots. Use `UUID=` (or `LABEL=`/`PARTUUID=`).
> - **A missing mount-point directory.** `mount -a` fails if the target path does not exist. Create it (`mkdir -p`) or use the `x-mount.mkdir` option.

> *A device field in `/etc/fstab` is not "which disk". It is "which disk, found how". `/dev/vdb` is found by the order the disks were detected at boot; `UUID=` is found by a value written once and never touched again. Only one of those still means the same disk next boot.*
