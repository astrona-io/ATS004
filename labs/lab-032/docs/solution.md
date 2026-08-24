# Solution Guide: LVM pvmove Migrations and Reduction

This guide demonstrates how to migrate LVM extents and reduce Volume Groups.

---

## Step 1: Perform the Live Extent Migration

Move all active extents off `disk1` to `disk2` using `pvmove`:
```bash
sudo pvmove /dev/disk/by-id/virtio-lab032-disk1 /dev/disk/by-id/virtio-lab032-disk2
```
*(This command will display progress percentages as blocks are copied live)*

---

## Step 2: Remove the Free Disk from the VG

Reduce the `vg_migration` Volume Group:
```bash
sudo vgreduce vg_migration /dev/disk/by-id/virtio-lab032-disk1
```

---

## Step 3: Remove the LVM Physical Volume Metadata

Wipe the LVM signature:
```bash
sudo pvremove /dev/disk/by-id/virtio-lab032-disk1
```

---

## Step 4: Verify the New Layout

1. Check that the Volume Group has only one PV (`disk2`):
   ```bash
   sudo vgdisplay -v vg_migration
   ```
2. Verify that your data on `/mnt/lvm-migration` is still active:
   ```bash
   cat /mnt/lvm-migration/migration-marker.txt
   ```
