# Solution Walkthrough

---

## Step 1: Grow the volume

```bash
sudo lvextend -L +200M /dev/vg_resize/lv_data
sudo resize2fs /dev/vg_resize/lv_data
```

Expect the LV to report a new size around 500M, and `resize2fs` to grow
the filesystem into it online (the volume stays mounted throughout).

---

## Step 2: Shrink the volume — filesystem first, always

```bash
sudo umount /mnt/resize-data
sudo e2fsck -f /dev/vg_resize/lv_data
sudo resize2fs /dev/vg_resize/lv_data 350M
sudo lvreduce -L 350M /dev/vg_resize/lv_data
```

`resize2fs` shrinks the filesystem's own superblock to 350M *before*
`lvreduce` removes a single extent from the volume. Reversing this order
would hand back extents the filesystem still believed it owned.

---

## Step 3: Remount and verify

```bash
sudo mount /dev/vg_resize/lv_data /mnt/resize-data
cat /mnt/resize-data/marker.txt
sudo lvs vg_resize/lv_data
```

Expect `marker.txt` to read exactly as it did before either resize, and
`lvs` to report `lv_data` at roughly 350M.
