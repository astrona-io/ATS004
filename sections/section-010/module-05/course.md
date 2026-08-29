# /etc/fstab in Depth

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-010/module-05/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-010/module-05/playground
> astrona destroy section-010-module-05-playground
> ```

A `mount` command lasts until reboot. To have a filesystem come back automatically every boot, you describe it in `/etc/fstab` — the filesystem table. The kernel and systemd read this file early in startup and mount everything it lists.

`/etc/fstab` is also where a small mistake stops a server from booting into a normal state. This module covers the six fields of an entry, which identifier to use for the device, the options that matter, and how to check an entry is safe *before* you rely on it at boot.

## Learning objectives

After this module you can:

- Name the six fields of an `/etc/fstab` line and what each controls.
- Choose `UUID=` / `LABEL=` / `PARTUUID=` over a `/dev/sdX` path and say why.
- Pick sensible mount options, including when to add `nofail` and `_netdev`.
- Set the `dump` and `pass` fields correctly for a data filesystem, the root filesystem, and swap.
- Test an entry with `sudo mount -a` and `findmnt --verify` before trusting it at boot.

## Before you start

You should know how to mount a filesystem manually (`mount`, `umount`) and read `blkid` / `lsblk` output.

The linked playground gives you an Ubuntu server VM with two spare 1 GB ext4 filesystems (labels `DATA1`, `DATA2`), `/etc/fstab` backed up to `/etc/fstab.orig`, and passwordless `sudo`. Editing `/etc/fstab` in the VM is safe — it is a throwaway machine and the backup restores it. Run the command blocks below in that VM after `astrona ssh section-010-module-05-playground`.

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
| 4 | options | `defaults,nofail` | Comma-separated mount options (below). |
| 5 | dump | `0` | Used by the old `dump` backup tool. Almost always `0`. |
| 6 | pass | `2` | `fsck` order at boot: `0` = never, `1` = root filesystem only, `2` = other local filesystems. Network and swap are `0`. |

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

## Options that matter

`defaults` expands to `rw,suid,dev,exec,auto,nouser,async` — a reasonable baseline. The ones you add or change most often:

- **`nofail`** — if the device is missing at boot, skip it instead of failing. Essential for removable and secondary disks; **do not** put it on a filesystem the system needs to function.
- **`_netdev`** — the mount needs the network; wait for networking and don't attempt it in the early boot stage. Required for `nfs`, `cifs`, iSCSI.
- **`noatime`** — don't write an access timestamp on every read. A common, safe performance win.
- **`ro`** — mount read-only.
- **`x-systemd.*`** — hand behaviour to systemd (automount, timeouts). Covered in the next module.

The `dump` field is a historical artifact — set it to `0`. The `pass` field is the one to get right: `1` for root, `2` for other local filesystems that should be checked, `0` for anything that should not be (network mounts, swap, and filesystems like XFS that check themselves).

## Testing before you trust it

An unmountable entry without `nofail` can leave a booting system dropping to an emergency shell. Check every new entry while the system is up and easy to fix.

`sudo mount -a` tries to mount everything in the file and reports failures. `findmnt --verify` parses `/etc/fstab` and flags problems — unknown filesystem types, missing mount points, suspicious options — without mounting anything.

> [!TIP]
> **Try it — catch a broken entry before reboot**
>
> ```sh
> echo "UUID=00000000-0000-0000-0000-000000000000  /mnt/nope  ext4  defaults  0  2" | sudo tee -a /etc/fstab
> findmnt --verify
> sudo mount -a
> ```
>
> Expect something like:
>
> ```text
> /mnt/nope
>    [E] unreachable on boot required source UUID=00000000-... not found
>
> mount: /mnt/nope: can't find UUID=00000000-0000-0000-0000-000000000000.
> ```
>
> `findmnt --verify` marks the line with `[E]` and `mount -a` fails on it — loudly, but harmlessly, because the system is already running. At boot, that same failure on a non-`nofail` entry is what forces the emergency shell. Remove the bad line, or restore the backup: `sudo cp /etc/fstab.orig /etc/fstab`.

> [!WARNING]
> **Common pitfalls**
>
> - **Naming devices by `/dev/sdX` or `/dev/vdX`.** These can change between boots. Use `UUID=` (or `LABEL=`/`PARTUUID=`).
> - **Forgetting `nofail` on a secondary disk.** If that disk is absent or unformatted at boot, a non-`nofail` entry fails the mount and the boot drops to a recovery shell. Add `nofail` to anything the system does not strictly need.
> - **Missing `_netdev` on a network mount.** Without it, the system tries to mount before networking is up; the mount fails and boot may stall waiting for it.
> - **A wrong `pass` value.** Setting `2` (or `1`) on a network mount or swap makes boot attempt an `fsck` that cannot run. Network mounts and swap are `0`.
> - **Editing `/etc/fstab` and rebooting without testing.** Always run `sudo mount -a` and `findmnt --verify` first, while the machine is still reachable.
> - **A missing mount-point directory.** `mount -a` fails if the target path does not exist. Create it (`mkdir -p`) or use the `x-mount.mkdir` option.
