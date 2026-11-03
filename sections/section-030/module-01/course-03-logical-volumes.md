# Logical Volumes

A volume group is a pool of physical extents. This part carves the first named allocation out of it — a logical volume — and covers where LVM's default allocator actually places the extents it hands out.

## Carving out a logical volume

`lvcreate -n <name> -L <size> <vg>` grabs enough extents from the VG's free pool to satisfy `<size>`, rounding up to a whole number of PEs, and records that assignment as the LV's extent list (the extent model — this is the exact list `lvs -o +devices` reads back). `<name>` is again an invented label, this time for the LV — below it's `shared_documents`; `<vg>` is the VG name, `company_storage`. The result is a block device at `/dev/<vg>/<name>` (also reachable as `/dev/mapper/<vg>-<name>`), built by device-mapper replaying that list. `-n` sets the name; `-L` sets an absolute size (`-l` instead takes a count of extents or a percentage of the VG).

The resulting device is formatted and mounted exactly like a partition — nothing above the LV layer can tell its extents came from a pool rather than one contiguous region.

### Where the allocator actually puts extents

By default `lvcreate` uses the **normal** allocation policy: it prefers extents that keep the LV's data on as few PVs as possible and, within a PV, prefers contiguous runs — but it is not required to honor either preference if the free space doesn't cooperate. A request that fits inside one PV's free space typically lands entirely on that PV; a request bigger than any single PV's remaining free extents spans PVs automatically, with no error and no prompt. This is why `lvs -o +devices` is worth checking after every `lvcreate`, not just when something goes wrong — it's the only place that confirms where the allocator actually put the data, as opposed to where you assumed it would.

### See it in your playground

**1. Carve 200 MiB out of the VG and name the new LV:**
<!-- astrona:playground:renew -->

```sh
sudo lvcreate -n shared_documents -L 200M company_storage
```
```text
  Logical volume "shared_documents" created.
```
`shared_documents` is the LV name being invented here; `company_storage` (the last argument) is the VG it's drawn from.

**2. Check where the allocator actually put it:**
```sh
sudo lvs -o +devices
```
```text
  LV                VG              Attr       LSize   Devices
  shared_documents  company_storage -wi-a----- 200.00m /dev/vdc(0)
```
`Devices` reads `/dev/vdc(0)` — "starting at physical extent 0 of that PV." A 200 MiB request fits inside one disk's free space, so the normal allocator kept all of it on `/dev/vdc` rather than spreading it across `/dev/vdc` and `/dev/vdd`. Ask for more than one disk's remaining free space and this column would list both.

**3. Put an ext4 filesystem on the new block device:**
```sh
sudo mkfs.ext4 /dev/company_storage/shared_documents
```
```text
(mkfs prints a short creation summary — block count, inode count, UUID; the exact text isn't important here)
```
The path is `/dev/<vg-name>/<lv-name>` — LVM builds this automatically from the two names you chose in step 1, you never type it separately.

**4. Create a mount point and mount the new filesystem:**
```sh
sudo mkdir -p /mnt/shared_documents
sudo mount /dev/company_storage/shared_documents /mnt/shared_documents
```
```text
(no output — both commands are silent on success)
```
No news is good news: `mkdir` and `mount` only print something when they fail.

**5. Confirm it's mounted and see the usable size:**
```sh
df -h /mnt/shared_documents
```
```text
  Filesystem                                    Size  Used Avail Use% Mounted on
  /dev/mapper/company_storage-shared_documents  172M   24K  158M   1% /mnt/shared_documents
```
`df` shows an ordinary ext4 filesystem — the LVM layers underneath are invisible to it. Note the device is reported as `/dev/mapper/company_storage-shared_documents`, not the `/dev/company_storage/shared_documents` path you typed — both names point at the same device-mapper device, `mapper` is just its other spelling. The size (172M) is a little under the 200 MiB you asked for, because the filesystem's own metadata takes a cut of the block device.

> *`lvcreate` doesn't allocate space so much as append rows to an extent-assignment list, drawn by an allocator that prefers — but never guarantees — one disk. `lvs -o +devices` is the only command that tells you what actually happened.*

## Common pitfalls

> [!WARNING]
>
> - **`pvcreate` on the wrong device.** Running it on a disk that holds a filesystem or the system disk (`/dev/vda` here) overwrites the start of that device. Confirm with `lsblk` and `blkid` first, and match on the disk's serial rather than its `vdX` letter — letters can shift between boots, serials do not. Same care as `mkfs`.
> - **Trying to format the volume group.** A VG is a pool, not a device. There is no `/dev/company_storage` to `mkfs`. You format the *logical volume* (`/dev/company_storage/shared_documents`).
> - **Confusing the VG name with a path.** `vgcreate` and `lvcreate` take the VG *name* (`company_storage`); `mkfs`/`mount` take the LV *path* (`/dev/company_storage/shared_documents`).
> - **Forgetting the filesystem step.** `lvcreate` gives you a raw block device — an extent list, replayed by device-mapper. Until you `mkfs` it, there is nothing for a filesystem driver to mount.
> - **Assuming an LV sits on one disk.** The `normal` allocator prefers fewer PVs, but a large enough request spans PVs silently. Use `lvs -o +devices` to see where it actually landed, every time, not just when troubleshooting.

## Your mission: LVM Fundamentals: PV, VG, and LV Allocation Lab

You can now turn a raw disk into a PV, pool it into a VG, and carve out a formatted and mounted LV. The mission asks you to build the volume group `vg_data`, carve a 500M logical volume `lv_storage`, format it with ext4, and mount it at `/mnt/lvm-storage`.

The mission runs on its own training ship. A playground cannot be paused, so remove it first to free memory; it always starts clean again:

```sh
astrona destroy section-030-module-01-playground
```

Then start the mission and connect to it:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-030/module-01/labs/lab-01
astrona ssh ats-004-lab-031
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-030/module-01/labs/lab-01
```

When the mission is done, remove it and start a fresh playground:

```sh
astrona destroy ats-004-lab-031
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-030/module-01/playground
```

## Your mission: LVM Fundamentals: Pooling PVs Across Disks Lab

You also saw that an LV can span disks when one disk is too small. The mission asks you to pool two disks into the volume group `vg_pool`, carve an LV `lv_wide` of 1500M that no single disk can hold, and mount it at `/mnt/lvm-wide`.

The mission runs on its own training ship. A playground cannot be paused, so remove it first to free memory; it always starts clean again:

```sh
astrona destroy section-030-module-01-playground
```

Then start the mission and connect to it:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-030/module-01/labs/lab-02
astrona ssh ats-004-lab-037
```

Read the task in [`question.md`](./labs/lab-02/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-030/module-01/labs/lab-02
```

When the mission is done, remove it and start a fresh playground:

```sh
astrona destroy ats-004-lab-037
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-030/module-01/playground
```
