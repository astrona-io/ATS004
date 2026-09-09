# Solution Guide: /etc/fstab in Depth

Follow these steps to format the disk and add a correct, persistent fstab entry.

---

## Step 1: Identify and Format the Disk

Find the raw disk:
```bash
lsblk
```
Format it `ext4` with the label `APPDATA`:
```bash
sudo mkfs.ext4 -L APPDATA /dev/disk/by-id/virtio-lab015-data1
```

---

## Step 2: Create the Mount Point

```bash
sudo mkdir -p /mnt/appdata
```

---

## Step 3: Get the UUID

```bash
UUID=$(sudo blkid -s UUID -o value /dev/disk/by-id/virtio-lab015-data1)
echo "$UUID"
```

---

## Step 4: Add the fstab Entry

Append a line keyed by `UUID=`, with `nofail` (so a missing disk never blocks boot), `noatime` (skip access-time writes), `dump` = `0`, and `pass` = `2` (a non-root local filesystem):

```bash
echo "UUID=$UUID  /mnt/appdata  ext4  defaults,nofail,noatime  0  2" | sudo tee -a /etc/fstab
```

---

## Step 5: Apply and Verify

Mount everything not yet mounted:
```bash
sudo mount -a
findmnt /mnt/appdata
```

Check the whole table is safe before trusting it at boot:
```bash
sudo findmnt --verify
```
No `[E]` lines should appear for the new entry.
