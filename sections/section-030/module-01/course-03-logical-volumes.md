# Part 3 — Logical Volumes

> Prerequisite: [Part 2 — Physical Volumes & Volume Groups](./course-02-pv-and-vg.md). Next: [Module landing page](./course.md).

Parts 1–2 built a pool of physical extents. This part carves the first named allocation out of it — a logical volume — and covers where LVM's default allocator actually places the extents it hands out.

## Carving out a logical volume

`lvcreate -n <name> -L <size> <vg>` grabs enough extents from the VG's free pool to satisfy `<size>`, rounding up to a whole number of PEs, and records that assignment as the LV's extent list (Part 1's model — this is the exact list `lvs -o +devices` reads back). `<name>` is again an invented label, this time for the LV — below it's `shared_documents`; `<vg>` is the VG name from Part 2, `company_storage`. The result is a block device at `/dev/<vg>/<name>` (also reachable as `/dev/mapper/<vg>-<name>`), built by device-mapper replaying that list. `-n` sets the name; `-L` sets an absolute size (`-l` instead takes a count of extents or a percentage of the VG).

The resulting device is formatted and mounted exactly like a partition — nothing above the LV layer can tell its extents came from a pool rather than one contiguous region.

### Where the allocator actually puts extents

By default `lvcreate` uses the **normal** allocation policy: it prefers extents that keep the LV's data on as few PVs as possible and, within a PV, prefers contiguous runs — but it is not required to honor either preference if the free space doesn't cooperate. A request that fits inside one PV's free space typically lands entirely on that PV; a request bigger than any single PV's remaining free extents spans PVs automatically, with no error and no prompt. This is why `lvs -o +devices` is worth checking after every `lvcreate`, not just when something goes wrong — it's the only place that confirms where the allocator actually put the data, as opposed to where you assumed it would.

> [!TIP]
> **Try it — carve, format, and mount an LV**
>
> **1. Carve 200 MiB out of the VG and name the new LV:**
> ```sh
> sudo lvcreate -n shared_documents -L 200M company_storage
> ```
> ```text
>   Logical volume "shared_documents" created.
> ```
> `shared_documents` is the LV name being invented here; `company_storage` (the last argument) is the VG it's drawn from.
>
> **2. Check where the allocator actually put it:**
> ```sh
> sudo lvs -o +devices
> ```
> ```text
>   LV                VG              Attr       LSize   Devices
>   shared_documents  company_storage -wi-a----- 200.00m /dev/vdc(0)
> ```
> `Devices` reads `/dev/vdc(0)` — "starting at physical extent 0 of that PV." A 200 MiB request fits inside one disk's free space, so the normal allocator kept all of it on `/dev/vdc` rather than spreading it across `/dev/vdc` and `/dev/vdd`. Ask for more than one disk's remaining free space and this column would list both.
>
> **3. Put an ext4 filesystem on the new block device:**
> ```sh
> sudo mkfs.ext4 /dev/company_storage/shared_documents
> ```
> ```text
> (mkfs prints a short creation summary — block count, inode count, UUID; the exact text isn't important here)
> ```
> The path is `/dev/<vg-name>/<lv-name>` — LVM builds this automatically from the two names you chose in step 1, you never type it separately.
>
> **4. Create a mount point and mount the new filesystem:**
> ```sh
> sudo mkdir -p /mnt/shared_documents
> sudo mount /dev/company_storage/shared_documents /mnt/shared_documents
> ```
> ```text
> (no output — both commands are silent on success)
> ```
> No news is good news: `mkdir` and `mount` only print something when they fail.
>
> **5. Confirm it's mounted and see the usable size:**
> ```sh
> df -h /mnt/shared_documents
> ```
> ```text
>   Filesystem                                    Size  Used Avail Use% Mounted on
>   /dev/mapper/company_storage-shared_documents  172M   24K  158M   1% /mnt/shared_documents
> ```
> `df` shows an ordinary ext4 filesystem — the LVM layers underneath are invisible to it. Note the device is reported as `/dev/mapper/company_storage-shared_documents`, not the `/dev/company_storage/shared_documents` path you typed — both names point at the same device-mapper device, `mapper` is just its other spelling. The size (172M) is a little under the 200 MiB you asked for, because the filesystem's own metadata takes a cut of the block device.

> [!WARNING]
> **Common pitfalls**
>
> - **`pvcreate` on the wrong device.** Running it on a disk that holds a filesystem or the system disk (`/dev/vda` here) overwrites the start of that device. Confirm with `lsblk` and `blkid` first, and match on the disk's serial rather than its `vdX` letter — letters can shift between boots, serials do not. Same care as `mkfs`.
> - **Trying to format the volume group.** A VG is a pool, not a device. There is no `/dev/company_storage` to `mkfs`. You format the *logical volume* (`/dev/company_storage/shared_documents`).
> - **Confusing the VG name with a path.** `vgcreate` and `lvcreate` take the VG *name* (`company_storage`); `mkfs`/`mount` take the LV *path* (`/dev/company_storage/shared_documents`).
> - **Forgetting the filesystem step.** `lvcreate` gives you a raw block device — an extent list, replayed by device-mapper. Until you `mkfs` it, there is nothing for a filesystem driver to mount.
> - **Assuming an LV sits on one disk.** The `normal` allocator prefers fewer PVs, but a large enough request spans PVs silently. Use `lvs -o +devices` to see where it actually landed, every time, not just when troubleshooting.

> *`lvcreate` doesn't allocate space so much as append rows to an extent-assignment list, drawn by an allocator that prefers — but never guarantees — one disk. `lvs -o +devices` is the only command that tells you what actually happened.*

## Reference

- `man lvcreate` — the `--alloc` flag (`normal`, `contiguous`, `cling`, `anywhere`) for overriding the default allocation policy when placement matters.
- `man lvs` — the `-o +devices` column reference used throughout this module and the next.
