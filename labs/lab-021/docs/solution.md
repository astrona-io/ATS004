# Solution Guide: SSHFS User-space Mounting

This guide walks through configuring an ad-hoc user-space mount using SSHFS.

---

## Step 1: Create the Mount Point

Create a local mount point:
```bash
sudo mkdir -p /mnt/sshfs-share
```

---

## Step 2: Configure FUSE permissions

Ensure FUSE is configured to allow user-space mount sharing. Verify or append `user_allow_other` in `/etc/fuse.conf`:
```bash
sudo sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf
```

---

## Step 3: Perform the SSHFS Mount

Run `sshfs` to mount the remote path. Pass the passphrase using `password_stdin` to prevent prompts, and bypass strict key host verification:
```bash
echo "password123" | sudo sshfs -o password_stdin,allow_other,StrictHostKeyChecking=no sshuser@127.0.0.1:/opt/remote-data /mnt/sshfs-share
```

---

## Step 4: Verify the Mount

List the contents of the share to confirm readability:
```bash
ls -l /mnt/sshfs-share
```
Verify the mount details:
```bash
mount | grep sshfs
```
