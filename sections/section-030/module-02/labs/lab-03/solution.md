# Solution Guide: Growing a Live Pool with vgextend, Then Evacuating a Disk

This guide walks through adding capacity to an already-live Volume Group and then using that new capacity to retire the original disk — the full add-then-remove cycle.

---

## Step 1: Initialize the Second Disk as a PV

```bash
sudo pvcreate /dev/disk/by-id/virtio-lab038-disk2
```

---

## Step 2: Extend the Existing Volume Group

`disk1` has no free extents of its own — `vg_live` needs somewhere to send the migrated data before `pvmove` can run at all:

```bash
sudo vgextend vg_live /dev/disk/by-id/virtio-lab038-disk2
```

Confirm the pool now spans two PVs:

```bash
sudo vgs vg_live
sudo pvs
```

---

## Step 3: Migrate Every Extent Off disk1

```bash
sudo pvmove /dev/disk/by-id/virtio-lab038-disk1
```

*(This prints live progress percentages as extents are mirrored and re-pointed. `lv_active` stays mounted and readable/writable throughout.)*

Confirm the extent list moved:

```bash
sudo lvs -o +devices
```

`Devices` should no longer list `disk1` at all.

---

## Step 4: Remove the Now-Empty Disk from the VG

```bash
sudo vgreduce vg_live /dev/disk/by-id/virtio-lab038-disk1
```

---

## Step 5: Wipe the LVM Signature

```bash
sudo pvremove /dev/disk/by-id/virtio-lab038-disk1
```

---

## Step 6: Verify the Final Layout and Data

```bash
sudo pvs
sudo vgdisplay -v vg_live
cat /mnt/lvm-live/*.txt
```

`vg_live` should now show exactly one PV — `disk2` — and the file(s) under `/mnt/lvm-live` should read exactly as they did before the migration started.
