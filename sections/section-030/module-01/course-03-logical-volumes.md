# Part 3 — Logical Volumes

> Prerequisite: [Part 2 — Physical Volumes & Volume Groups](./course-02-pv-and-vg.md). Next: [Module landing page](./course.md).

Parts 1–2 built a pool of physical extents. This part carves the first named allocation out of it — a logical volume — and covers where LVM's default allocator actually places the extents it hands out.

## Carving out a logical volume

`lvcreate -n <name> -L <size> <vg>` grabs enough extents from the VG's free pool to satisfy `<size>`, rounding up to a whole number of PEs, and records that assignment as the LV's extent list (Part 1's model — this is the exact list `lvs -o +devices` reads back). The result is a block device at `/dev/<vg>/<name>` (also reachable as `/dev/mapper/<vg>-<name>`), built by device-mapper replaying that list. `-n` sets the name; `-L` sets an absolute size (`-l` instead takes a count of extents or a percentage of the VG).

The resulting device is formatted and mounted exactly like a partition — nothing above the LV layer can tell its extents came from a pool rather than one contiguous region.

### Where the allocator actually puts extents

By default `lvcreate` uses the **normal** allocation policy: it prefers extents that keep the LV's data on as few PVs as possible and, within a PV, prefers contiguous runs — but it is not required to honor either preference if the free space doesn't cooperate. A request that fits inside one PV's free space typically lands entirely on that PV; a request bigger than any single PV's remaining free extents spans PVs automatically, with no error and no prompt. This is why `lvs -o +devices` is worth checking after every `lvcreate`, not just when something goes wrong — it's the only place that confirms where the allocator actually put the data, as opposed to where you assumed it would.

> [!TIP]
> **Try it — carve, format, and mount an LV**
>
> ```sh
> sudo lvcreate -n applv -L 200M vgdata
> sudo lvs -o +devices
> sudo mkfs.ext4 /dev/vgdata/applv
> sudo mkdir -p /mnt/applv
> sudo mount /dev/vgdata/applv /mnt/applv
> df -h /mnt/applv
> ```
>
> Expect something like (middle `lvs` columns trimmed here for width):
>
> ```text
>   Logical volume "applv" created.
>
>   LV    VG     Attr       LSize   ... Devices
>   applv vgdata -wi-a----- 200.00m     /dev/vdc(0)
>
>   Filesystem                Size  Used Avail Use% Mounted on
>   /dev/mapper/vgdata-applv  172M   24K  158M   1% /mnt/applv
> ```
>
> `lvs -o +devices` shows the extents for `applv` came from `/dev/vdc` (a 200 MiB request fits on one disk, so the normal allocator kept it there). `/dev/vdc(0)` means "starting at physical extent 0 of that PV". After `mkfs.ext4` and `mount`, `df` shows an ordinary ext4 filesystem — the LVM layers underneath are invisible to it, and the reported size is a little under 200 MiB because the filesystem's own metadata takes a cut. Request a size larger than one disk's free space and `Devices` would list both PVs, with no different command and no warning.

> [!WARNING]
> **Common pitfalls**
>
> - **`pvcreate` on the wrong device.** Running it on a disk that holds a filesystem or the system disk (`/dev/vda` here) overwrites the start of that device. Confirm with `lsblk` and `blkid` first, and match on the disk's serial rather than its `vdX` letter — letters can shift between boots, serials do not. Same care as `mkfs`.
> - **Trying to format the volume group.** A VG is a pool, not a device. There is no `/dev/vgdata` to `mkfs`. You format the *logical volume* (`/dev/vgdata/applv`).
> - **Confusing the VG name with a path.** `vgcreate` and `lvcreate` take the VG *name* (`vgdata`); `mkfs`/`mount` take the LV *path* (`/dev/vgdata/applv`).
> - **Forgetting the filesystem step.** `lvcreate` gives you a raw block device — an extent list, replayed by device-mapper. Until you `mkfs` it, there is nothing for a filesystem driver to mount.
> - **Assuming an LV sits on one disk.** The `normal` allocator prefers fewer PVs, but a large enough request spans PVs silently. Use `lvs -o +devices` to see where it actually landed, every time, not just when troubleshooting.

> *`lvcreate` doesn't allocate space so much as append rows to an extent-assignment list, drawn by an allocator that prefers — but never guarantees — one disk. `lvs -o +devices` is the only command that tells you what actually happened.*

## Reference

- `man lvcreate` — the `--alloc` flag (`normal`, `contiguous`, `cling`, `anywhere`) for overriding the default allocation policy when placement matters.
- `man lvs` — the `-o +devices` column reference used throughout this module and the next.
