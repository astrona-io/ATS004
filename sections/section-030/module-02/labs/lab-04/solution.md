# Solution Guide: Removing One PV Out of Three, With Mixed Extents

This guide covers removing a single PV from a Volume Group whose Logical Volume already has extents spread across every disk in the pool — not just the simpler one-disk-holds-everything case.

---

## Step 1: Confirm the Current Spread

```bash
sudo lvs -o +devices
```

The `Devices` column should list three entries, one per disk — proof `lv_data` is not sitting on a single PV.

---

## Step 2: Check There's Enough Room to Evacuate disk2 Without a New Disk

```bash
sudo pvs -o pv_name,pv_used,pv_free
```

Compare `disk2`'s `pv_used` figure against the combined `pv_free` of `disk1` and `disk3`. Here it comfortably fits — no `vgextend` is needed for this one.

---

## Step 3: Migrate Every Extent Off disk2

```bash
sudo pvmove /dev/disk/by-id/virtio-lab039-disk2
```

*(Progress percentages print live. `lv_data` stays mounted and usable the entire time.)*

Confirm it moved:

```bash
sudo lvs -o +devices
```

`disk2` should no longer appear anywhere in `Devices` — only `disk1` and `disk3` now.

---

## Step 4: Remove the Now-Empty Disk from the VG

```bash
sudo vgreduce vg_split /dev/disk/by-id/virtio-lab039-disk2
```

---

## Step 5: Wipe the LVM Signature

```bash
sudo pvremove /dev/disk/by-id/virtio-lab039-disk2
```

---

## Step 6: Verify the Final State

```bash
sudo pvs
sudo vgs vg_split
cat /mnt/lvm-split/*.txt
```

`vg_split` should show exactly two PVs (`disk1` and `disk3`), `lv_data` should be unchanged in size, and the file(s) under `/mnt/lvm-split` should read exactly as before — removing one PV out of three worked the same way removing one PV out of two would have.
