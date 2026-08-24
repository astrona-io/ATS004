# Solution Guide: NFS Enterprise Network Sharing

Follow this guide to export and mount directories using NFS.

---

## Step 1: Add the NFS Export configuration

Open `/etc/exports` in an editor:
```bash
sudo nano /etc/exports
```
Append the read-only share line:
```text
/var/nfs/public *(ro,sync,no_subtree_check)
```

---

## Step 2: Reload Exports & Restart NFS Server

Apply the changes:
```bash
sudo exportfs -ra
sudo systemctl restart nfs-kernel-server
```

---

## Step 3: Mount the Share

1. Create the mount directory:
   ```bash
   sudo mkdir -p /mnt/nfs-share
   ```
2. Mount the remote share:
   ```bash
   sudo mount -t nfs 127.0.0.1:/var/nfs/public /mnt/nfs-share
   ```

---

## Step 4: Verify read-only access

Ensure you can read files, but writes fail:
```bash
ls -l /mnt/nfs-share
sudo touch /mnt/nfs-share/test-write
```
The touch command should output `Permission denied` or `Read-only file system`.
