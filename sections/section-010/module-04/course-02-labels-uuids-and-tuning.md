# Labels, UUIDs and Tuning Check Intervals

Astronaut, a repaired cargo hold is only useful if the ship docks the right hold at the right hatch every time it launches. This page shows how to give a filesystem a name that never moves, how to dock it by that name, and how to tell `tune2fs` when the repair crew should run a full check on its own.

## Stable identifiers: labels and UUIDs

Device names are not a safe way to point at a disk. This section shows why, and the two names that stay put instead.

### Why `/dev/vdb` is not enough

The kernel hands out names like `/dev/vdb` in the order it finds the disks. Those names are **not stable**. Attach another disk, or boot with a USB drive plugged in, and yesterday's `/dev/vdb` can be today's `/dev/vdc`.

`/etc/fstab` is the ship's logbook of holds to dock at every launch. A line in it that names `/dev/vdb` would then dock the wrong hold.

### The serial number and the painted name

Two stable names solve this. Both live in the superblock, the master manifest at the start of the filesystem, but they behave differently:

- The **UUID** (universally unique identifier) is the hold's serial number. `mkfs` writes a random 128-bit value into the superblock when it builds the filesystem. It is unique and does not change for the life of the filesystem, whatever you do to the disk afterwards.
- The **label** is the hold's painted name: a short string you choose. You can set it and change it whenever you like. It is handy, but you must keep labels unique yourself. The filesystem does not check.

### The tools that read and write them

Three tools do this work:

- `blkid` ("block ID") reads the filesystem headers. `blkid <device>` prints both the label and the UUID. `blkid -s UUID -o value <device>` prints only the UUID value, with nothing around it.
- `tune2fs -L <label> <device>` sets or changes the label directly in the superblock. It works on ext filesystems only. XFS keeps its superblock in a different format, so it needs a different tool: `xfs_admin -L`.
- `findmnt <path>` ("find mount") shows what is docked at a hatch, and which device the name pointed to.

With a label or UUID you can dock with `mount LABEL=<label> <dir>` or `mount UUID=<uuid> <dir>`.

## Relabel and dock by UUID

Now you try both names on the spare disk. The disk must be unmounted and is usually `/dev/vdb`; confirm the name with `lsblk -f` before you run the commands.

### Paint a new name

<!-- astrona:playground:renew -->

Change the label, then read the result back:

```sh
sudo tune2fs -L "DB_REPLICA" /dev/vdb
sudo blkid /dev/vdb
```

Expect something like:

```text
/dev/vdb: LABEL="DB_REPLICA" UUID="3f2b1c9a-7d6e-4a5b-8c0d-1e2f3a4b5c6d" BLOCK_SIZE="4096" TYPE="ext4"
```

The label changed from `OLD_LABEL` to `DB_REPLICA`. The UUID did not change, and yours will be a different value.

### Dock by serial number

Make a hatch, dock the hold by its UUID, check it, and undock it again:

```sh
sudo mkdir -p /mnt/db-data
sudo mount UUID="$(sudo blkid -s UUID -o value /dev/vdb)" /mnt/db-data
findmnt /mnt/db-data
sudo umount /mnt/db-data
```

Expect something like this from `findmnt`:

```text
TARGET     SOURCE   FSTYPE OPTIONS
/mnt/db-data /dev/vdb ext4  rw,relatime
```

The mount worked without naming `/dev/vdb` in the `mount` command. `mount` looked for the filesystem whose superblock holds that UUID, so it finds the right disk whatever name the kernel gave it today. `findmnt` then shows which device that turned out to be.

### The same name in the logbook

This is the reason the first field of an `/etc/fstab` line is normally `UUID=...`. A line has six fields: the name of the filesystem, the hatch, the filesystem type, the mount options, and two numbers. The first number is for the old `dump` backup tool, and the second sets the order of the boot-time check (`0` means never, `2` means after the root filesystem). Write the UUID with no quotes around it:

```text
UUID=<UUID> /mnt/db-data ext4 defaults 0 2
```

Replace `<UUID>` with the value from `sudo blkid -s UUID -o value /dev/vdb`, and edit the file with `sudo` (for example `sudo nano /etc/fstab`). A bad line in `/etc/fstab` can stop the ship at its next launch, so check it before any reboot. `sudo findmnt --verify` reads the file and reports problems, and `sudo mount -a` docks every listed hold that is not docked yet, just as systemd does at boot.

## Tuning check intervals

`tune2fs` also decides when the system forces a full check on its own. It keeps two separate counters for this in the same superblock:

- `-c N` plans a check after every `N` mounts.
- `-i <time>` plans one after a calendar interval, such as `2m` for two months.

When either counter runs out, the next boot runs a full `fsck`, even if the journal says all is clean. This is a regular inspection by the repair crew, not crash recovery. That is why it does not depend on the journal replay that the kernel runs at each mount.

`-c 0 -i 0` turns both counters off. Many servers do this. They trust the journal and outside monitoring, and they do not want a surprise full check that makes a reboot take much longer than planned.

### Set a mount-count check

Plan a check after every 20 mounts, then read the counters back:

```sh
sudo tune2fs -c 20 /dev/vdb
sudo tune2fs -l /dev/vdb | grep -Ei 'mount count'
```

Expect something like:

```text
Setting maximal mount count to 20

Mount count:              0
Maximum mount count:      20
```

`Maximum mount count` is now 20, so the 20th mount triggers an automatic `fsck`. Your `Mount count` may be higher than `0`, because each mount, including the one above, adds one. Run `sudo tune2fs -c 0 /dev/vdb` to turn the check off again.

## Common pitfalls

> [!WARNING]
> - **`tune2fs` on a filesystem that is not ext.** `tune2fs` only handles ext2, ext3 and ext4 superblocks. On XFS it fails; use `xfs_admin` (for example `xfs_admin -L LABEL /dev/vdb`). Check the type with `blkid` first.
> - **Mounting by `/dev/sdX` in `/etc/fstab`.** Device names can change between boots. Use `UUID=` (or `LABEL=` if you keep your labels unique) so the right filesystem always mounts.
> - **Giving two filesystems the same label.** Nothing stops you, and then `LABEL=` can dock the wrong hold. A UUID does not have this problem.

> *The UUID and the label both live in the superblock. One is made once and never changes; the other you set yourself and can break by copying it. That is the whole reason `/etc/fstab` uses `UUID=` by default.*

## Your mission: Filesystem Repairs, Labeling, & UUIDs

You can now repair an unmounted filesystem, give it a label and dock it by its UUID. The mission gives you a damaged disk: repair it, label it `RECOVERED_VOL`, and make it dock at `/mnt/recovered` by UUID from `/etc/fstab`.

The mission runs on its own training ship. A playground cannot be paused, so remove it first to free memory; it always starts clean again:

```sh
astrona destroy section-010-module-04-playground
```

Then start the mission and connect to it:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-010/module-04/labs/lab-01
astrona ssh ats-004-lab-013
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-04/labs/lab-01
```

When the mission is done, remove it and start a fresh playground:

```sh
astrona destroy ats-004-lab-013
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-010/module-04/playground
```
