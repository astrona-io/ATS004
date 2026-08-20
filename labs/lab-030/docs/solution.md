# Solution

## Step 1: Survey the current LVM stack and identify the target PV

```bash
sudo pvs
sudo vgs
sudo lvs -o lv_name,vg_name,devices
```

`pvs`/`vgs`/`lvs` give one-line-per-object summaries. `lvs -o devices` is the key one here: it shows which PV(s) each LV's extents actually live on — this is how you identify "the disk that holds `vol1/data1`" without assuming a specific `/dev/vdX` letter, since extra disks aren't guaranteed to attach in a predictable order relative to the VM's own root disk. Capture it into a variable so the rest of the steps don't have to re-derive it:

```bash
TARGET_PV=$(sudo lvs --noheadings -o devices vol1/data1 | sed -E 's/\(.*\)//; s/^[[:space:]]+//; s/[[:space:]]+$//')
echo "$TARGET_PV"
```

`lvs -o devices` prints each extent's backing PV with a `(start-extent)` suffix (e.g. `/dev/vdb(0)`); the `sed` strips that suffix and surrounding whitespace, leaving just the device path.

```bash
sudo pvdisplay "$TARGET_PV"
```

`pvdisplay` on the specific PV shows "Allocated PE" — how many physical extents on this exact disk are currently in use by an LV. If this is non-zero, `pvmove` is mandatory before `vgreduce` will succeed.

## Step 2: Confirm the VG has room elsewhere to receive the moved extents

```bash
sudo vgs -o vg_name,vg_free vol1
```

`pvmove` needs somewhere in the same VG to put the data currently on `$TARGET_PV`. `vol1`'s other PV has enough free extents for this to proceed.

## Step 3: Move all extents off the target PV

Check `man 8 vgreduce` — its notes section is explicit that a physical volume still holding allocated extents cannot be removed, which is exactly why this step exists before `vgreduce`. Cross-reference `man 8 pvmove` for what the relocation itself guarantees (an online, atomic-per-extent copy).

```bash
sudo pvmove "$TARGET_PV"
```

`pvmove` walks every logical extent currently mapped to `$TARGET_PV` and copies it, live, onto free extents on the VG's remaining PVs, updating each affected LV's extent table atomically as each piece completes. The command blocks until finished and is safe to run against mounted, in-use LVs — that's the whole point of doing it this way instead of unmounting and copying manually.

## Step 4: Remove the target PV from vol1

```bash
sudo vgreduce vol1 "$TARGET_PV"
```

With `$TARGET_PV` now holding zero allocated extents (thanks to Step 3), `vgreduce` can safely detach it from `vol1` — it updates the VG metadata to drop the PV from its member list. Confirm:

```bash
sudo pvs "$TARGET_PV"
```

It should now show either no VG association or appear as an orphaned PV (`VG` column blank).

## Step 5: (Optional but clean) Strip old PV metadata before reuse

```bash
sudo pvremove "$TARGET_PV"
```

This wipes the LVM PV label from `$TARGET_PV`, returning it to a genuinely raw, unlabeled disk. It's not strictly required — `vgcreate` will happily initialize an already-labeled-but-orphaned PV — but doing it explicitly avoids any ambiguity about the disk's prior VG membership and matches good exam hygiene of leaving no stale metadata behind.

## Step 6: Create the new volume group vol2 on the target disk

```bash
sudo vgcreate vol2 "$TARGET_PV"
```

`vgcreate` initializes `$TARGET_PV` as a PV (if it isn't already one) and creates a brand-new VG named `vol2` with that single PV as its only member. Verify:

```bash
sudo vgs vol2
sudo pvs "$TARGET_PV"
```

`pvs` should now show `$TARGET_PV` with `VG` column reading `vol2`.

## Step 7: Create the 50M logical volume p1

Check `man 8 lvcreate` — the `-L`/`--size` section documents unit suffixes (`M`, `G`, etc.) and notes sizes are rounded to the VG's physical extent size, which explains why the resulting LV may not show exactly `50.00m`.

```bash
sudo lvcreate -L 50M -n p1 vol2
```

`-L 50M` requests a fixed-size LV of 50 mebibytes (rounded to the nearest whole extent as discussed above), `-n p1` names it, and `vol2` is the VG to carve it from. Verify:

```bash
sudo lvs vol2
sudo lvdisplay /dev/vol2/p1
```

`lvdisplay` confirms the exact size, the device path (`/dev/vol2/p1`, which is a symlink to `/dev/mapper/vol2-p1`), and that the LV is active (`LV Status: available`).

## Step 8: Format the new logical volume with ext4

```bash
sudo mkfs.ext4 /dev/vol2/p1
```

This is the same `mkfs.ext4` as any other block device — the LV device node behaves exactly like a disk or partition from the filesystem layer's perspective, which is the entire point of the device-mapper abstraction underneath LVM. Do **not** run `mkfs` against `$TARGET_PV` directly at this point — that device is now a PV member of `vol2`, and formatting it directly would corrupt the LVM metadata that makes `vol2`/`p1` work.

## Verification

```bash
sudo pvs
# expect: the target disk now listed with VG = vol2, no leftover reference to vol1

sudo vgs
# expect: vol1 no longer lists the target disk as a member (fewer PVs / smaller total size than before);
#         vol2 exists with 1 PV (the target disk)

sudo lvs vol2
# expect: p1  vol2  ... 52.00m (or similar, rounded to extent size)

sudo blkid /dev/vol2/p1
# expect: TYPE="ext4"
```

## Command Summary

```bash
sudo pvs
sudo vgs
sudo lvs -o lv_name,vg_name,devices
TARGET_PV=$(sudo lvs --noheadings -o devices vol1/data1 | sed -E 's/\(.*\)//; s/^[[:space:]]+//; s/[[:space:]]+$//')
sudo pvdisplay "$TARGET_PV"
sudo vgs -o vg_name,vg_free vol1
sudo pvmove "$TARGET_PV"
sudo vgreduce vol1 "$TARGET_PV"
sudo pvremove "$TARGET_PV"
sudo vgcreate vol2 "$TARGET_PV"
sudo vgs vol2
sudo lvcreate -L 50M -n p1 vol2
sudo lvs vol2
sudo lvdisplay /dev/vol2/p1
sudo mkfs.ext4 /dev/vol2/p1
```
