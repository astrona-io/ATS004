# Solution Guide: Growing an XFS Volume Live

This guide grows an XFS-formatted Logical Volume — the same two-step shape as growing ext4 (device first, then filesystem), but with XFS's own resize tool instead of `resize2fs`.

---

## Step 1: Grow the Block Device

```bash
sudo lvextend -L +400M /dev/vg_xfs/lv_xfs
```

Same command as ext4 — `lvextend` doesn't know or care what filesystem sits on top of the LV.

---

## Step 2: Grow the Filesystem With the XFS-Specific Tool

```bash
sudo xfs_growfs /mnt/lvm-xfs
```

Two things are different from the ext4 path:

- `xfs_growfs` takes the **mount point** (`/mnt/lvm-xfs`), not the device path — unlike `resize2fs`, which takes the device.
- Running `sudo resize2fs /dev/vg_xfs/lv_xfs` here would simply fail — `resize2fs` only understands ext-family filesystems.

---

## Step 3: Verify

```bash
df -h /mnt/lvm-xfs
cat /mnt/lvm-xfs/*.txt
```

`df` should report a larger size than before step 1, and the file already on the volume should read exactly as it did before either resize.
