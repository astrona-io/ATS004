# Solution Guide: LUKS Block-level Encryption

This guide walks you through setting up an encrypted LUKS volume.

---

## Step 1: Identify the Target Disk

Find the unformatted 2GB disk:
```bash
lsblk
```
Assume the device is `/dev/vdb`. Verify its serial:
```bash
ls -l /dev/disk/by-id/virtio-lab012-raw
```

---

## Step 2: Encrypt the Disk with LUKS

Format the disk as a LUKS container. Enter `YES` (uppercase) when prompted, and use the passphrase `securepassword123`:
```bash
echo "securepassword123" | sudo cryptsetup luksFormat /dev/vdb
```

---

## Step 3: Open the Encrypted Mapping

Map the encrypted device to `/dev/mapper/secure_volume`:
```bash
echo "securepassword123" | sudo cryptsetup open /dev/vdb secure_volume
```

---

## Step 4: Format the Mapped Device

Create an ext4 filesystem on the mapped virtual block device:
```bash
sudo mkfs.ext4 /dev/mapper/secure_volume
```

---

## Step 5: Mount and Verify

1. Create the mount directory:
   ```bash
   sudo mkdir -p /mnt/secure-data
   ```
2. Mount the volume:
   ```bash
   sudo mount /dev/mapper/secure_volume /mnt/secure-data
   ```
3. Create the marker file:
   ```bash
   sudo touch /mnt/secure-data/sealed
   ```
