# Solution Guide: Filesystem Repairs, Labeling, & UUIDs

Follow these steps to repair, label, and persistently mount a corrupted filesystem.

---

## Step 1: Repair the Filesystem

Identify the device name:
```bash
lsblk
```
Run `fsck` on the unmounted block device to repair corruptions. Answer yes (`-y`) to all repair prompts:
```bash
sudo fsck -y /dev/disk/by-id/virtio-lab013-corrupt
```

---

## Step 2: Assign a Label

Label the filesystem `RECOVERED_VOL`:
```bash
sudo tune2fs -L RECOVERED_VOL /dev/disk/by-id/virtio-lab013-corrupt
```

---

## Step 3: Retrieve the UUID

Get the UUID of the filesystem:
```bash
sudo blkid /dev/disk/by-id/virtio-lab013-corrupt
```
Copy the long UUID string (e.g., `a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d`).

---

## Step 4: Configure Persistent Mounting

1. Create the mount directory:
   ```bash
   sudo mkdir -p /mnt/recovered
   ```
2. Open `/etc/fstab` in an editor:
   ```bash
   sudo nano /etc/fstab
   ```
3. Add a persistent entry using the UUID:
   ```text
   UUID=<YOUR-UUID-HERE> /mnt/recovered ext4 defaults 0 2
   ```

---

## Step 5: Mount and Confirm

Mount the volume using fstab:
```bash
sudo mount -a
```
Confirm it is mounted correctly:
```bash
df -h | grep /mnt/recovered
```
