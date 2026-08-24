# Solution Guide: Swap File Allocation & Security

Follow these steps to safely allocate and configure a swap file.

---

## Step 1: Allocate space for the Swap File

Allocate 512MB at `/swapfile`:
```bash
sudo dd if=/dev/zero of=/swapfile bs=1M count=512
```

---

## Step 2: Set Secure Permissions

Allow only root access (`0600`):
```bash
sudo chmod 600 /swapfile
```

---

## Step 3: Format and Enable Swap

1. Format the file:
   ```bash
   sudo mkswap /swapfile
   ```
2. Activate the swap:
   ```bash
   sudo swapon /swapfile
   ```

---

## Step 4: Configure Persistence

1. Open `/etc/fstab`:
   ```bash
   sudo nano /etc/fstab
   ```
2. Append the persistent swap file mapping:
   ```text
   /swapfile none swap sw 0 0
   ```
3. Verify swap is active:
   ```bash
   swapon --show
   ```
