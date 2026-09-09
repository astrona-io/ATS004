# Solution Guide: Network autofs Wildcard Mounts

Learn how to configure scalable on-demand wildcard storage connections using autofs.

---

## Step 1: Configure the Master Map

Open `/etc/auto.master` in an editor:
```bash
sudo nano /etc/auto.master
```
Append the indirect map definition with a 120-second timeout:
```text
/mnt/net /etc/auto.net --timeout=120
```

---

## Step 2: Configure the Wildcard Map

Create the `/etc/auto.net` mapping file:
```bash
sudo nano /etc/auto.net
```
Add the wildcard rule to resolve client connections dynamically:
```text
* -fstype=nfs,ro,soft 127.0.0.1:/var/nfs/exports/&
```

---

## Step 3: Enable the Configuration

1. Restart autofs:
   ```bash
   sudo systemctl restart autofs
   ```
2. Test dynamic mounting by navigating to `/mnt/net/project-alpha`:
   ```bash
   ls -la /mnt/net/project-alpha
   ```
3. Check the active network mount:
   ```bash
   mount | grep project-alpha
   ```
