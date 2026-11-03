# The Hardware Tree & the Mount List

`/proc` holds generated files about processes and the whole ship. `/sys` uses the same generate-on-read idea for hardware. This part reads device facts from `/sys`, then looks at `/proc/mounts`, the kernel's own list of what is docked.

## Reading the hardware tree: `/sys`

Start with a question: what is the sector size of the spare disk? You can ask a tool, or you can read one file. This section shows the file and the mechanism behind it.

> As an analogy: `/sys` is the spec sheet for every part on the ship, kept current by the core. Want a disk's sector size? There is a file for it. The analogy breaks down because some `/sys` files are dials, not only readouts: LED brightness, the CPU speed policy or a device's power state.

### How `/sys` is built

`/sys` shows the kernel's device model. Every bus, device and driver is an object, and sysfs shows each object as a directory with one file per attribute. A driver gives each attribute a `show` function, which runs when you read the file. If the driver also gives a `store` function, it runs when you write to the file.

A file with no `store` function is read-only by construction, not only by its permission bits. A file with both is a real control. That is why "some `/sys` files are controls" is the model working as designed, not an exception.

### Where to look

`/sys/class/block/<dev>/` holds block-device attributes. `/sys/class/net/<iface>/` holds network-interface attributes. `/sys/block/<dev>/queue/` holds I/O queue settings. Each leaf is a plain file backed by one driver's functions.

<!-- astrona:playground:renew -->

### See it in your playground

Read the sector size and the capacity of the spare disk, then the network addresses. Confirm the disk name with `lsblk` first if yours is not `vdb`.

```sh
lsblk -dn -o NAME,SIZE /dev/vdb
cat /sys/class/block/vdb/queue/hw_sector_size
cat /sys/class/block/vdb/size
cat /sys/class/net/*/address
```

Expect something like this (addresses differ on your ship):

```text
vdb    1G
512
2097152
00:00:00:00:00:00
52:54:00:a1:b2:c3
```

`hw_sector_size` is the disk's physical sector size in bytes. `size` is its capacity in 512-byte sectors, so 2097152 × 512 bytes is 1 GiB. The `address` files are the network cards' hardware addresses. No special tool did this. Each value came from the driver's `show` function the moment you read the file.

## The authoritative mount list: `/proc/mounts`

The logbook `/etc/fstab` says what should be docked. This section is about the list of what is docked right now. It must come from the core itself, not from a file that someone keeps up to date.

### Why the kernel's list wins

The kernel keeps one entry per active mount. Reading `/proc/mounts` (the same as `/proc/self/mounts`) walks that live list and writes it out. No second record exists that could fall out of step.

In the past `/etc/mtab` was a separate text file that `mount` and `umount` updated. It could drift from reality after a crash or a change in another mount namespace. On current systems `/etc/mtab` is a symlink to `/proc/self/mounts`, so the gap is closed. `mount` with no arguments and `findmnt` also read the kernel's data. When in doubt, read `/proc/mounts`.

### See it in your playground

Compare the three views of the root mount.

```sh
ls -l /etc/mtab
grep ' / ' /proc/mounts
findmnt --noheadings --output SOURCE,TARGET,FSTYPE /
```

Expect something like this:

```text
lrwxrwxrwx 1 root root 19 Aug 29 12:00 /etc/mtab -> /proc/self/mounts
/dev/vda1 / ext4 rw,relatime 0 0
/dev/vda1 / ext4
```

`/etc/mtab` points straight at `/proc/self/mounts`. The root line shows the device, mount point, type and options exactly as the kernel's list holds them.

> *`/sys` and `/proc/mounts` use the same trick as `/proc/meminfo`: a file that is really a function call, so what you read is never out of date.*

## Common pitfalls

> [!WARNING]
> - **Assuming every `/sys` file is read-only.** Many are, but a file with a `store` function is a control. Writing to the wrong one can disturb a running ship. Change a `/sys` value only when you know what it does.
> - **Trusting a copy of the mount list.** `/etc/mtab` is a symlink today. `/proc/mounts` is the source.
> - **Hard-coding the device name.** `vdb` may be a different letter on your ship. Confirm with `lsblk` before you read `/sys/class/block/<dev>/`.
