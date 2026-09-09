# Part 1 — The Hardware Tree & the Mount List

> Prerequisite: none — this is the first part of the module (assumes the previous module's `/proc` mechanism). Next: [Part 2 — sysctl: Viewing, Changing & Persisting](./course-02-sysctl-viewing-changing-persisting.md).

`/proc` (previous module) is generated files describing processes. `/sys` is the same generated-on-read mechanism aimed at hardware, and `/proc/mounts` is one more generated file worth knowing by name — the kernel's own live list of what's mounted, immune to the drift a separate tracking file could have.

## Reading the hardware tree: `/sys`

> As an analogy: `/sys` is a spec sheet for every part in the machine, kept current by the kernel. Want a disk's sector size? There is a file for it. The analogy breaks down because some `/sys` files are writable and act as controls (LED brightness, CPU governor, device power state), not just readouts.

The mechanism behind both halves of that analogy: `/sys` exposes the kernel's internal device model — every bus, device, and driver is a **kobject**, and sysfs renders each kobject as a directory with one file per attribute. Each attribute file is backed by a pair of functions the driver registers: a `show` function that runs when you read the file (same generate-on-read idea as `/proc`), and — only if the driver defines one — a `store` function that runs when you write to it. A file with no `store` function is read-only by construction, not by permission bit alone; one with both is a genuine control. That's why "some `/sys` files are controls" isn't an exception to the model, it's the model working as designed.

`/sys` is organised by category to match that device model. `/sys/class/block/<dev>/` holds block-device attributes; `/sys/class/net/<iface>/` holds network-interface attributes; `/sys/block/<dev>/queue/` holds I/O queue settings. Each leaf is a plain file, backed by exactly one driver's `show`/`store` pair.

> [!TIP]
> **Try it — read device attributes as files**
>
> ```sh
> lsblk -dn -o NAME,SIZE /dev/vdb
> cat /sys/class/block/vdb/queue/hw_sector_size
> cat /sys/class/block/vdb/size
> cat /sys/class/net/*/address
> ```
>
> Expect something like:
>
> ```text
> vdb    1G
> 512
> 2097152
> 00:00:00:00:00:00
> 52:54:00:a1:b2:c3
> ```
>
> `hw_sector_size` is the disk's physical sector size in bytes; `size` is its capacity in 512-byte sectors (2097152 × 512 = 1 GiB). The `address` files under `/sys/class/net/` are interface MAC addresses. No special utility — each is the block or network driver's own `show` function, called the instant you read the file.

## The authoritative mount list: `/proc/mounts`

`/proc/mounts` (equivalently `/proc/self/mounts`) applies the same generate-on-read mechanism to one more kernel structure: the current process's mount namespace, which the kernel maintains as a list of `vfsmount` objects — one per active mount. Reading `/proc/mounts` walks that live list and renders it; there is no separate record to fall out of sync, because nothing is recorded anywhere except the list itself.

Historically `/etc/mtab` *was* a separate text file that user-space `mount`/`umount` kept updated by hand, and it could drift from reality if a mount changed by another path (a crash mid-update, a mount namespace change, a container). On current systems `/etc/mtab` is just a symlink to `/proc/self/mounts`, closing that gap entirely — `mount` with no arguments and `findmnt` read the kernel's data directly, not a maintained copy. When in doubt, read `/proc/mounts`.

> [!TIP]
> **Try it — compare the views**
>
> ```sh
> ls -l /etc/mtab
> grep ' / ' /proc/mounts
> findmnt --noheadings --output SOURCE,TARGET,FSTYPE /
> ```
>
> Expect something like:
>
> ```text
> lrwxrwxrwx 1 root root 19 Aug 29 12:00 /etc/mtab -> /proc/self/mounts
>
> /dev/vda1 / ext4 rw,relatime 0 0
>
> /dev/vda1 / ext4
> ```
>
> `/etc/mtab` points straight at `/proc/self/mounts`, so there is no separate file to fall out of sync. The root line from `/proc/mounts` shows the device, mount point, filesystem type, and options exactly as the kernel's `vfsmount` list has them, generated at the moment of the read.

> *`/sys` and `/proc/mounts` are the same trick as `/proc/meminfo`: a file that is really a function call, so what you read is never stale — the tradeoff is that "stale" was never possible, but neither is "cached for speed."*

## Reference

- `man 5 sysfs` — the kobject/attribute model this part's mechanism section summarises.
- `man 8 findmnt` — the modern tool for querying `/proc/self/mounts`, with filtering `mount`'s output alone doesn't offer.
