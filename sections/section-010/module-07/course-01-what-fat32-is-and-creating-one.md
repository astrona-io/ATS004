# What FAT32 Is & Creating One

Every ext4 filesystem stores, next to each file's data, a Unix owner, a group and permission bits. That stored information is why `chmod` and `chown` work. This part covers a filesystem that was never designed to store any of it, why makers of removable media use it anyway, and how you create one.

## Why an old format is still the default

FAT32 is older than most of the Linux tools you use, yet it is still on almost every new USB stick. This section explains what FAT32 is made of and why that simple design is exactly what makes it popular.

### A flat table and nothing more

FAT32 stands for File Allocation Table, 32-bit. It comes from MS-DOS. On the disk, it keeps one flat table that maps each file to a chain of storage blocks. There are no inodes (the cargo tags that record owner and size on ext4), no journal and no idea of a file "owner" at all.

That simple design is why every operating system still reads it. Windows, macOS and Linux all have FAT32 support built in, with no extra drivers. ext4 is different: Windows and macOS need extra tools to read it. A USB stick formatted as ext4 works perfectly on Linux and is a mystery to a Windows laptop. A USB stick formatted as FAT32 works everywhere. That is the whole reason camera makers, USB drive vendors and router firmware all default to it.

In space terms: ext4 is a cargo hold where every crate carries a tag with its owner's name and who may open it. FAT32 is a plain shelf list with only a name and a shelf number. The shelf list can be read on any ship in the galaxy, but it can never tell you whose crate is whose.

### FAT32 and vfat: two names, one thing

In Linux, the kernel driver for FAT32 is called **vfat** (virtual FAT). It is the driver that added long file names on top of the original FAT format, which only allowed names like `REPORT.TXT`. You see both names: FAT32 is the format on the disk, and `vfat` is the filesystem type that shows up in `mount` output and in `/etc/fstab`.

## Creating a FAT32 filesystem

You build FAT32 with `mkfs.vfat`. This section shows the one option you must not forget, and then the command itself.

### Why you always pass `-F 32`

The FAT format has three generations: FAT12, FAT16 and FAT32. They differ in how large a disk they can handle. On a small enough disk, `mkfs.vfat` picks FAT16 unless you tell it otherwise.

The `-F 32` option forces FAT32, whatever the size of the disk. This matters because exam tasks, and some real hardware such as very small flash chips, would otherwise end up with FAT16. FAT16 is a different layout on the disk, even though most everyday commands do not show the difference.

### See it in action

Here is the command on a Linux machine with a blank spare disk at `/dev/vdb`. It finds the disk and formats it as FAT32 with the label `USBDATA`:

```sh
lsblk
sudo mkfs.vfat -F 32 -n USBDATA /dev/vdb
```

Expect something like:

```text
mkfs.fat 4.2 (2021-01-31)
```

The `-n USBDATA` option sets the volume label (the hold's painted name) while formatting. It does the same job as the label option of `mkfs.ext4`. `mkfs.vfat` prints almost nothing when it works. There is no long summary like the one `mkfs.ext4` prints, because there is much less structure to build.

## Labeling after the fact

Sometimes you need to rename a FAT32 filesystem without formatting it again. This section shows the tool for that job.

### `fatlabel` instead of `tune2fs`

For ext4 you change the label with `tune2fs -L`. FAT32 is a completely different format on the disk, with its own tools, so it uses a separate tool: `fatlabel`. Called with only a device, `fatlabel` prints the current label. Called with a device and a new name, it writes the new label.

### See the label change

Read the label, change it, and read it again:

```sh
sudo fatlabel /dev/vdb
sudo fatlabel /dev/vdb TRAVEL_DRIVE
sudo fatlabel /dev/vdb
```

Expect something like:

```text
USBDATA

TRAVEL_DRIVE
```

The first call shows the old label, the second writes the new one, and the third shows the new label. `blkid /dev/vdb` would now also show `LABEL="TRAVEL_DRIVE" TYPE="vfat"`. That is the same way every other filesystem in this course is identified; only the `TYPE` is different.

## Common pitfalls

> [!WARNING]
> - **Forgetting `-F 32` on a small disk.** `mkfs.vfat` may pick FAT16 instead, a different layout with a smaller size limit. Always pass `-F 32` when the task asks for FAT32.
> - **Looking for `vfat` in the task text and `FAT32` in the tools, or the other way around.** FAT32 is the format; `vfat` is the type name in `mount`, `blkid` and `/etc/fstab`. Both describe the same filesystem.
> - **Trying `tune2fs -L` on a FAT32 disk.** `tune2fs` only works on the ext family. Use `fatlabel` for FAT32.
> - **Formatting the wrong disk.** `mkfs.vfat` overwrites whatever is on the device. Confirm the device with `lsblk` before you format.

> *FAT32 is not a smaller or older ext4. It is a different kind of filesystem, built with no idea of a file owner.*
