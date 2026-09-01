# Solution Guide: LVM PV, VG, and LV Allocation

This guide shows you how to initialize and configure basic LVM components.

---

## Step 1: Identify and Initialize Physical Volume (PV)

1. Find the 2GB raw disk:
   ```bash
   lsblk
   ```
   Assume the disk is `/dev/vdb` (or `/dev/disk/by-id/virtio-lab031-disk1`).
2. Initialize it as an LVM Physical Volume:
   ```bash
   sudo pvcreate /dev/disk/by-id/virtio-lab031-disk1
   ```

---

## Step 2: Create the Volume Group (VG)

Create a Volume Group named `vg_data` incorporating the new PV:
```bash
sudo vgcreate vg_data /dev/disk/by-id/virtio-lab031-disk1
```

---

## Step 3: Create the Logical Volume (LV)

Carve out an LV named `lv_storage` with a size of 500MB:
```bash
sudo lvcreate -L 500M -n lv_storage vg_data
```

---

## Step 4: Format and Mount

1. Format the new LV with ext4:
   ```bash
   sudo mkfs.ext4 /dev/vg_data/lv_storage
   ```
2. Create the mount directory:
   ```bash
   sudo mkdir -p /mnt/lvm-storage
   ```
3. Mount the logical volume:
   ```bash
   sudo mount /dev/vg_data/lv_storage /mnt/lvm-storage
   ```
