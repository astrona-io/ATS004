# Solution Guide: Swap Partition Formatting & Priorities

Learn how to manage swap priorities inside `/etc/fstab`.

---

## Step 1: Format the Swap Partition

Format the secondary drive:
```bash
sudo mkswap /dev/disk/by-id/virtio-lab042-swapdisk
```

---

## Step 2: Enable Swap with Priority

Activate the swap partition with priority 10:
```bash
sudo swapon -p 10 /dev/disk/by-id/virtio-lab042-swapdisk
```

---

## Step 3: Configure fstab Persistence

1. Open `/etc/fstab`:
   ```bash
   sudo nano /etc/fstab
   ```
2. Update or append the mappings to specify priorities:
   ```text
   /swapfile none swap sw,pri=5 0 0
   /dev/disk/by-id/virtio-lab042-swapdisk none swap sw,pri=10 0 0
   ```
3. Re-read swap spaces or inspect priorities:
   ```bash
   cat /proc/swaps
   ```
