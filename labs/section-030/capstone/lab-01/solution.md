# Solution Guide (Offline & Exam Friendly)

This step-by-step guide explains how to manage LVM (Logical Volume Manager) structures by visually identifying devices, eliminating complex scripting, and using built-in command help.

---

## Step 1: Identify the Disk to Remove

You need to find which physical volume (PV) holds the logical volume (LV) `vol1/data1`.

1. If you do not remember how to inspect LVM, list the available LVM commands by typing `pv` or `vg` or `lv` and pressing `TAB` twice. Or run:
   ```bash
   man lvm
   ```
2. Display all LVs along with their backing devices:
   ```bash
   sudo lvs -o lv_name,vg_name,devices
   ```
3. Look at the output row where the `LV` is `data1` and the `VG` is `vol1`. Under the `Devices` column, look at the disk path (for example, `/dev/vdb(0)`).
   - Ignore the parenthesis and any numbers inside them.
   - Note the base physical volume name (e.g., `/dev/vdb`).
   - *For the rest of this guide, we assume this disk is `/dev/vdX`. Replace `/dev/vdX` with your actual device name.*

---

## Step 2: Check if the Volume Group has Free Space

Since `vol1/data1` is on `/dev/vdX`, you must move its data to another physical disk inside `vol1` before removing `/dev/vdX`.

Check if `vol1` has enough free space on its other disks:
```bash
sudo vgs -o vg_name,vg_free,pv_count
```
*Verify that there is enough space to receive the data currently stored on `/dev/vdX`.*

---

## Step 3: Move Data off the Target Disk

1. Move all allocated extents from `/dev/vdX` to the other disk(s) in `vol1`:
   ```bash
   sudo pvmove /dev/vdX
   ```
   *This command runs online. The system moves the data block-by-block while the filesystem is still active.*
2. Confirm the disk now has zero allocated extents:
   ```bash
   sudo pvs /dev/vdX
   ```
   *The "Attr" and free space columns should indicate that no extents are currently allocated on this PV.*

---

## Step 4: Remove the Disk from `vol1`

Remove the empty physical volume `/dev/vdX` from the volume group `vol1`:

```bash
sudo vgreduce vol1 /dev/vdX
```

---

## Step 5: Clean the Physical Volume Metadata (Optional but Recommended)

Remove LVM signatures from the disk so it is completely clean and ready for reuse:

```bash
sudo pvremove /dev/vdX
```

---

## Step 6: Create the New Volume Group `vol2`

Create a new volume group named `vol2` using the freed disk `/dev/vdX`:

```bash
sudo vgcreate vol2 /dev/vdX
```

---

## Step 7: Create the 50M Logical Volume `p1`

You need to carve a 50M logical volume named `p1` out of `vol2`.

1. If you do not remember how to specify size or name in `lvcreate`, run:
   ```bash
   lvcreate --help | grep -E 'size|name'
   ```
   *Or check `man lvcreate` to find that `-L` is used for size (e.g., `-L 50M`) and `-n` is used for name.*
2. Create the logical volume:
   ```bash
   sudo lvcreate -L 50M -n p1 vol2
   ```
3. Verify that the logical volume was created successfully:
   ```bash
   sudo lvs vol2
   ```

---

## Step 8: Format the Logical Volume with `ext4`

Format the new logical volume `/dev/vol2/p1` with the `ext4` filesystem:

```bash
sudo mkfs.ext4 /dev/vol2/p1
```
*Note: Do not format the raw device `/dev/vdX` directly. Doing so would overwrite LVM metadata and break the logical volume.*

---

## Verification

Confirm everything is configured correctly:

```bash
# 1. Check if LVM structures are correct
sudo pvs
sudo vgs
sudo lvs

# 2. Verify that the target disk is now part of vol2 and not vol1
sudo pvs

# 3. Confirm the new partition has ext4 filesystem
sudo blkid /dev/vol2/p1
```
