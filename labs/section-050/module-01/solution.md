# Solution Guide: autofs Direct Maps & Timeouts

This guide demonstrates setting up a direct map mount in autofs.

---

## Step 1: Install autofs

Ensure the autofs service is available:
```bash
sudo apt-get update -y
sudo apt-get install -y autofs
```

---

## Step 2: Configure the Master Map

Open `/etc/auto.master` and append a direct map entry:
```bash
sudo nano /etc/auto.master
```
Add the following line to direct autofs to read `/etc/auto.direct` and specify a 60-second timeout:
```text
/- /etc/auto.direct --timeout=60
```

---

## Step 3: Configure the Direct Map

Create `/etc/auto.direct` in an editor:
```bash
sudo nano /etc/auto.direct
```
Add the mounting rule for `/mnt/secure_archive`:
```text
/mnt/secure_archive -fstype=bind :/var/data/archive
```

---

## Step 4: Start and Verify

1. Restart the service:
   ```bash
   sudo systemctl restart autofs
   sudo systemctl enable autofs
   ```
2. Test the on-demand mount by listing `/mnt/secure_archive`:
   ```bash
   ls -la /mnt/secure_archive
   ```
3. Check active mount points:
   ```bash
   df -h | grep secure_archive
   ```
