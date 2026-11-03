# Solution Walkthrough

You will move cargo out of one hold, take that hold out of the pool `vol1`, and build a new pool `vol2` from it. Then you cut a small storage area from `vol2` and put shelves in it.

A few words first. A **physical volume** (PV) is one hold given to the pool. A **volume group** (VG) is the pool itself. A **logical volume** (LV) is a storage area cut from the pool. An **extent** is one standard-size crate slot in the pool. LVM keeps track of which crate slot sits on which hold.

Connect to the training ship first:

```sh
astrona ssh ats-004-lab-030
```

---

## Step 1: Find the Disk That Holds `vol1/data1`

If you forget the LVM commands, type `pv`, `vg` or `lv` and press `TAB` twice to list them, or read the manual page:

```sh
man lvm
```

Now ask LVM which disk each logical volume sits on:

```sh
sudo lvs -o lv_name,vg_name,devices
```

Find the row where `LV` is `data1` and `VG` is `vol1`. The `Devices` column shows a disk path with a number in brackets, for example `/dev/vdb(0)`. The number in brackets is the first extent; ignore it. Write down the disk path without it.

In the rest of this walkthrough that disk is called `/dev/vdX`. Replace it with your real device name. The letter on your ship may be different from any example, because the order of the disks is not fixed.

---

## Step 2: Check That `vol1` Has Room for the Cargo

Before LVM can take the hold out of the pool, the cargo on it must move to the other hold in `vol1`. Check that the pool has enough free space:

```sh
sudo vgs -o vg_name,vg_free,pv_count
```

Look at the `vol1` row. `VFree` must be larger than the space `data1` uses on `/dev/vdX`, and `#PV` should be `2`.

---

## Step 3: Move the Cargo Off the Disk

`pvmove` moves every used extent from `/dev/vdX` to the other physical volumes in the same volume group:

```sh
sudo pvmove /dev/vdX
```

The move runs while the ship flies. `vol1/data1` stays mounted and in use the whole time; LVM copies it crate by crate underneath.

Check that the disk is now empty:

```sh
sudo pvs /dev/vdX
```

Look at `PFree`: it should now equal `PSize`. That means no extents on this disk are in use.

---

## Step 4: Take the Disk Out of `vol1`

`vgreduce` removes an empty physical volume from a volume group:

```sh
sudo vgreduce vol1 /dev/vdX
```

LVM refuses this if the disk still holds extents. If you see that error, go back to Step 3.

---

## Step 5: Clean the LVM Label (Optional)

The disk still carries its physical volume label. You can wipe it so the disk is fully clean:

```sh
sudo pvremove /dev/vdX
```

This step is optional. `vgcreate` in the next step makes the disk a physical volume again anyway.

---

## Step 6: Create the Volume Group `vol2`

Build the new pool from the freed disk:

```sh
sudo vgcreate vol2 /dev/vdX
```

Look for a line that says volume group `vol2` was created.

---

## Step 7: Create the 50M Logical Volume `p1`

If you forget the options of `lvcreate`, search its help text:

```sh
lvcreate --help | grep -E 'size|name'
```

You can also read `man lvcreate`. `-L` sets the size (for example `-L 50M`) and `-n` sets the name.

Create the logical volume:

```sh
sudo lvcreate -L 50M -n p1 vol2
```

Check it:

```sh
sudo lvs vol2
```

You should see `p1` in volume group `vol2`. LVM rounds the size up to whole extents, so the size may show a little above `50.00m`. That is fine.

---

## Step 8: Format `p1` With ext4

Build the ext4 shelves on the new logical volume:

```sh
sudo mkfs.ext4 /dev/vol2/p1
```

Format the logical volume `/dev/vol2/p1`, never the raw disk `/dev/vdX`. Formatting the raw disk would overwrite the LVM label and destroy `vol2` and `p1`.

---

## Step 9: Check Your Work and Submit

The grader checks three things. Check them yourself first.

1. The disk that held `data1` is no longer in `vol1`, and it is now the physical volume of `vol2`:

   ```sh
   sudo pvs
   ```

   The `VG` column for `/dev/vdX` must say `vol2`, and `vol1` must show only the other disk.

2. `vol2/p1` exists and is close to 50M (the grader accepts 48 to 56 MiB):

   ```sh
   sudo lvs vol2/p1
   ```

3. `p1` has an ext4 filesystem:

   ```sh
   sudo blkid /dev/vol2/p1
   ```

   The output must contain `TYPE="ext4"`.

When all three look right, leave the ship and send it for grading:

```sh
astrona submit -c sections/section-030/capstone/labs/lab-01
```
