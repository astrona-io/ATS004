# Part 3 — vgreduce, and Growing/Shrinking a Volume

> Prerequisite: [Part 2 — Live Migration: pvmove](./course-02-pvmove-migration.md). Next: [Part 4 — Removing Any PV, and Physical Disk Safety](./course-04-removing-any-pv-and-safety.md).

Part 2 emptied a PV's extent list. This part covers the two directions you take the stack from here: retiring that now-empty disk (`vgreduce`, `pvremove`), and the opposite move — growing a volume and its filesystem while both stay live.

## Removing the emptied disk

With zero extents left assigned to it, `source_disk` can leave the pool. This is "tear down from the top", undoing the two build steps from Part 2 in reverse:

- `vgreduce <vg> <source>` detaches the PV from the volume group — the inverse of `vgextend`. It checks the VG metadata for any extent-list entry still pointing at this PV; if it finds one, it refuses. That check is the entire safety mechanism — `vgreduce` is not "smart" about data loss, it simply will not remove a PV that any LV's extent list still references, which is exactly why `pvmove` had to run first.
- `pvremove <source>` erases the LVM label `pvcreate` wrote, returning the disk to a plain, unclaimed state safe to physically unplug or repurpose.

Order matters for the same reason: `pvremove` refuses to run on a disk that is still a VG member, so `vgreduce` has to come first.

> [!TIP]
> **Try it — retire the source disk**
>
> (If your shell session from Part 2 is still open, `$source_disk` is already set — skip straight to step 2.)
>
> **1. Reload the disk-name variables if needed:**
> ```sh
> . /etc/playground-disks
> ```
> ```text
> (no output)
> ```
>
> **2. Detach the now-empty disk from the volume group:**
> ```sh
> sudo vgreduce company_storage "$source_disk"
> ```
> ```text
>   Removed "/dev/vdc" from volume group "company_storage"
> ```
> This is the check described above passing: `vgreduce` looked for any LV extent still pointing at `source_disk`, found none (Part 2's `pvmove` moved them all), and let it go.
>
> **3. Wipe the LVM label, returning the disk to a plain, unclaimed state:**
> ```sh
> sudo pvremove "$source_disk"
> ```
> ```text
>   Labels on physical volume "/dev/vdc" successfully wiped.
> ```
> `/dev/vdc` is now safe to physically unplug or repurpose — nothing on the system still considers it part of LVM.
>
> **4. Confirm it's gone from the PV list:**
> ```sh
> sudo pvs
> ```
> ```text
>   PV        VG              Fmt  Attr PSize    PFree
>   /dev/vdd  company_storage lvm2 a--  1020.00m  620.00m
>   /dev/vde  company_storage lvm2 a--  1020.00m 1020.00m
> ```
> Only two rows now — `source_disk` (`/dev/vdc`) no longer appears at all. The PV that received the migrated extents (`second_disk`, `/dev/vdd`) shows `620.00m` free — it gave up the space `shared_documents` now occupies. The untouched spare (`/dev/vde`) still shows its full `1020.00m`.
>
> **5. Confirm the VG is back to two members:**
> ```sh
> sudo vgs
> ```
> ```text
>   VG               #PV #LV #SN Attr   VSize VFree
>   company_storage   2   1   0 wz--n- 1.99g 1.60g
> ```
> `#PV 2`, down from Part 2's `3` — the sick disk is fully removed, and the whole operation ran with `shared_documents` mounted and serving reads and writes the entire time.

## Growing a volume live: lvextend then the filesystem

Enlarging a mounted volume is two independent steps, and the order is not optional: **grow the block device, then grow the filesystem inside it.** They are independent because they edit two different structures — `lvextend` appends entries to the LV's extent list (Part 1's model, same mechanism as everything else in this module); the filesystem has its own superblock fields recording its own size, written when it was created, and nothing about extending the LV touches that superblock. Until something rewrites it, the filesystem behaves exactly as if the extra space does not exist — `df` will not move a single byte after `lvextend` alone.

`lvextend` is the LV-layer counterpart of `vgextend`, one level up the stack: `vgextend` hands a disk's extents to the *pool*; `lvextend` hands some of the pool's free extents to a *volume*.

`lvextend -L +<size> <lv-path>` adds space. Unlike `vgextend`, it takes a size, and the `+` is critical:

- `lvextend -L +200M /dev/company_storage/shared_documents` — **add** 200 MiB to the current size.
- `lvextend -L 200M /dev/company_storage/shared_documents` — set the absolute size **to** 200 MiB. If `shared_documents` is already 400 MiB, this *shrinks* it and truncates the filesystem, destroying data — with no confirmation prompt.

Once the LV is bigger, rewrite the filesystem's own size fields to match: `resize2fs <lv-path>` for ext4, or `xfs_growfs <mountpoint>` for XFS (XFS's tool takes the *mount point*, not the device — and can only grow, never shrink; there is no supported XFS shrink path). `lvextend -r` runs both steps for you in one command, calling whichever resize tool matches the filesystem it detects.

> [!TIP]
> **Try it — add space and extend the ext4 filesystem**
>
> Block counts in your own output will depend on the filesystem's block size — don't worry if the exact numbers differ.
>
> **1. Check the size before touching anything, as a baseline:**
> ```sh
> df -h /mnt/shared_documents
> ```
> ```text
> Filesystem                                    Size Used Avail Use% Mounted on
> /dev/mapper/company_storage-shared_documents  359M ...  331M   1% /mnt/shared_documents
> ```
> Remember this `359M` — you'll compare the next two `df` calls against it.
>
> **2. Grow the block device by 200 MiB:**
> ```sh
> sudo lvextend -L +200M /dev/company_storage/shared_documents
> ```
> ```text
>   Size of logical volume company_storage/shared_documents changed from 400.00 MiB (100 extents) to 600.00 MiB (150 extents).
>   Logical volume company_storage/shared_documents successfully resized.
> ```
> Reported in both MiB and extents — 50 more 4 MiB extents is 200 MiB, appended to Part 1's extent list.
>
> **3. Check `df` again — this is the step that surprises people:**
> ```sh
> df -h /mnt/shared_documents
> ```
> ```text
> Filesystem                                    Size Used Avail Use% Mounted on
> /dev/mapper/company_storage-shared_documents  359M ...  331M   1% /mnt/shared_documents
> ```
> Identical to step 1. The block device is now 600 MiB underneath, but the filesystem's own superblock still says 400 MiB, so `df` — which reads the superblock, not the block device — reports no change at all. `lvextend` alone never touches the filesystem.
>
> **4. Rewrite the filesystem's superblock to use the new space:**
> ```sh
> sudo resize2fs /dev/company_storage/shared_documents
> ```
> ```text
> Filesystem at /dev/company_storage/shared_documents is mounted on /mnt/shared_documents; on-line resizing required
> The filesystem on /dev/company_storage/shared_documents is now 153600 (4k) blocks long.
> ```
> `153600` blocks of 4 KiB each ≈ 600 MiB — the superblock now matches the block device's real size.
>
> **5. Check `df` one more time:**
> ```sh
> df -h /mnt/shared_documents
> ```
> ```text
> Filesystem                                    Size Used Avail Use% Mounted on
> /dev/mapper/company_storage-shared_documents  553M ...  522M   1% /mnt/shared_documents
> ```
> Now it jumps, from `359M` to `553M` — only after `resize2fs`, never after `lvextend` alone. On XFS you would run `sudo xfs_growfs /mnt/shared_documents` instead of `resize2fs` in step 4 and see the same jump here.

## Shrinking a volume: lvreduce (ext4 only)

Shrinking reverses growing in every sense that matters, including the **order of operations** — and getting the order backwards is how this destroys data. Growing is safe device-first because the filesystem simply doesn't know about the new space yet; nothing is lost by waiting to tell it. Shrinking is the opposite: the LV's extent list is the *only* thing standing between "block still allocated" and "block handed back to the pool's free space." If you shrink the block device before the filesystem has relocated everything off the blocks being removed, `lvreduce` truncates extents the filesystem was still using — silent, immediate corruption, no undo.

So the rule inverts: **shrink the filesystem first, then shrink the LV.** Three steps, in this exact order:

1. **Unmount it.** Unlike growing, ext4 cannot shrink online — `resize2fs` refuses to shrink a mounted filesystem.
2. **`e2fsck -f <lv-path>`** — a forced check. `resize2fs` requires a clean, freshly-checked filesystem before it will shrink one; it will not gamble on relocating data blocks over metadata it hasn't verified.
3. **`resize2fs <lv-path> <new-size>`** — shrinks the filesystem's own superblock fields *first*, to a size at or below where the LV is about to end up. Only once every used block is confirmed to live inside that smaller boundary is it safe to run `lvreduce -L <new-size> <lv-path>` and hand the freed extents back to the VG.

`lvreduce -r` exists (it runs the resize2fs step for you, same as `lvextend -r` does for growing) — but because an undersized shrink target destroys data with no prompt, sizing it by hand and checking the filesystem's reported size before touching the LV is the safer habit for anything that is not disposable.

XFS still cannot shrink at all, by either tool — this is not a gap in `xfs_growfs`, it is a design choice in the XFS on-disk format (free space and allocation-group boundaries are not built to move inward). Reducing an XFS volume's *usable* space means creating a smaller LV and copying data across; there is no in-place path.

> [!TIP]
> **Try it — shrink `shared_documents` back down**
>
> **1. Unmount it — ext4 cannot shrink while mounted:**
> ```sh
> sudo umount /mnt/shared_documents
> ```
> ```text
> (no output)
> ```
>
> **2. Force a filesystem check — `resize2fs` requires one before it will shrink:**
> ```sh
> sudo e2fsck -f /dev/company_storage/shared_documents
> ```
> ```text
> e2fsck 1.47.0 ...
> /dev/company_storage/shared_documents: 12/... files, .../... blocks
> ```
> A clean pass, confirming there's nothing already wrong for `resize2fs` to gamble on.
>
> **3. Shrink the filesystem's own superblock first, to 350 MiB:**
> ```sh
> sudo resize2fs /dev/company_storage/shared_documents 350M
> ```
> ```text
> resize2fs 1.47.0 ...
> The filesystem on /dev/company_storage/shared_documents is now 89600 (4k) blocks long.
> ```
> This is the step order that matters: the filesystem now believes it is 350 MiB *before* the block device underneath has shrunk at all — every used block is confirmed to fit inside that smaller boundary.
>
> **4. Only now shrink the LV to match:**
> ```sh
> sudo lvreduce -L 350M /dev/company_storage/shared_documents
> ```
> ```text
>   Size of logical volume company_storage/shared_documents changed from 600.00 MiB to 350.00 MiB.
>   Logical volume company_storage/shared_documents successfully resized.
> ```
> By the time the LV loses 250 MiB of extents, nothing was still recorded as living on them — step 3 already moved everything the filesystem cared about out of that range. Reversing steps 3 and 4 would have handed back extents the filesystem still believed were its own, corrupting it.
>
> **5. Remount it:**
> ```sh
> sudo mount /dev/company_storage/shared_documents /mnt/shared_documents
> ```
> ```text
> (no output)
> ```
>
> **6. Confirm the new, smaller size:**
> ```sh
> df -h /mnt/shared_documents
> ```
> ```text
> Filesystem                                    Size Used Avail Use% Mounted on
> /dev/mapper/company_storage-shared_documents  339M ...  311M   1% /mnt/shared_documents
> ```
> Down from the `553M` you saw at the end of the growing walkthrough, matching the 350 MiB you asked for (minus the filesystem's own metadata overhead, same as every size in this module).

> [!WARNING]
> **Common pitfalls**
>
> - **`lvextend -L 20G` without the `+`.** Sets the absolute size. On a volume already larger than 20G it shrinks and truncates, destroying data with no prompt. Always write `-L +20G` to add.
> - **Forgetting the filesystem step when growing.** `lvextend` alone leaves the extra space unusable — the filesystem's superblock still records the old size. Follow with `resize2fs` / `xfs_growfs`, or use `lvextend -r`.
> - **Reversing the order when shrinking.** `lvreduce` before `resize2fs` truncates extents the filesystem still has data on — silent corruption, no confirmation, no undo. Filesystem first, always, for a shrink.
> - **Shrinking a mounted ext4 filesystem.** `resize2fs` refuses to shrink online. Unmount first (growing has no such restriction).
> - **`pvmove` with nowhere to move to.** It needs enough free extents on the *other* PVs in the VG (Part 2). Run `vgextend` with a fresh disk first if the pool is nearly full.
> - **`pvremove` before `vgreduce`.** A PV still referenced by any LV's extent list will not `pvremove` cleanly. Detach it with `vgreduce` first, and only after `pvmove` has emptied it.
> - **Assuming XFS can shrink.** Neither `resize2fs` nor `xfs_growfs` shrinks XFS — it is not implemented in the on-disk format, not just missing from the tool. There is no supported XFS shrink path; plan capacity accordingly, or migrate data to a smaller LV.

> *`vgreduce` refuses an occupied PV, `lvextend`/`lvreduce` leave the filesystem oblivious until you resize it — both are consequences of the same rule: the extent list and the filesystem's own superblock are two separate records, and only you keep them in sync, in the right order for the direction you're going.*

## Reference

- `man vgreduce` — `--removemissing` for the case where the PV is already gone (a real disk failure) rather than gracefully evacuated.
- `man resize2fs` / `man xfs_growfs` — the ext4 and XFS online-resize tools referenced above; check exact size syntax before use on a real filesystem.
