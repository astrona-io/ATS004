# Solution Guide: Pooling Multiple PVs into One VG

This guide shows you how to pool two physical disks into a single Volume Group and carve out a Logical Volume that spans both.

---

## Step 1: Identify and Initialize Both Physical Volumes (PV)

1. Find the two raw disks:
   ```bash
   lsblk
   ```
   They are reachable at `/dev/disk/by-id/virtio-lab037-disk1` and `/dev/disk/by-id/virtio-lab037-disk2`.
2. Initialize both as LVM Physical Volumes:
   ```bash
   sudo pvcreate /dev/disk/by-id/virtio-lab037-disk1 /dev/disk/by-id/virtio-lab037-disk2
   ```

---

## Step 2: Create the Volume Group (VG)

Pool both PVs into a single Volume Group named `vg_pool`:
```bash
sudo vgcreate vg_pool /dev/disk/by-id/virtio-lab037-disk1 /dev/disk/by-id/virtio-lab037-disk2
```

---

## Step 3: Create the Logical Volume (LV)

Carve out an LV named `lv_wide` at 1500M — bigger than either single ~1 GiB disk, so LVM has no choice but to draw extents from both:
```bash
sudo lvcreate -L 1500M -n lv_wide vg_pool
```

---

## Step 4: Format and Mount

1. Format the new LV with ext4:
   ```bash
   sudo mkfs.ext4 /dev/vg_pool/lv_wide
   ```
2. Create the mount directory:
   ```bash
   sudo mkdir -p /mnt/lvm-wide
   ```
3. Mount the logical volume:
   ```bash
   sudo mount /dev/vg_pool/lv_wide /mnt/lvm-wide
   ```

---

## Step 5: Confirm the Extents Span Both Disks

```bash
sudo lvs -o +devices
```

Expect the `Devices` column to list extents from *both* `virtio-lab037-disk1` and `virtio-lab037-disk2` — proof that pooling two PVs really does let one Logical Volume draw from more than one physical disk at once, which is the entire reason a Volume Group exists.
