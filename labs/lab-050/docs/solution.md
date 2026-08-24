# Solution Guide (Offline & Exam Friendly)

This step-by-step guide explains how to configure `autofs` to automatically mount a remote share on demand and unmount it after inactivity, showing you how to find map file formats using standard manual pages.

---

## Step 1: Install and Start Autofs

1. If you do not remember the exact package name for autofs, search your package manager:
   ```bash
   apt-cache search autofs   # On Debian/Ubuntu
   # or: dnf search autofs   # On RHEL/Fedora
   ```
2. Install and start the service:
   ```bash
   sudo apt-get install -y autofs
   sudo systemctl enable --now autofs
   ```

---

## Step 2: Create the Base Mount Directory

Create the base directory that `autofs` will watch. Note that you should **only** create the parent directory `/mnt/auto` — do not create the `/mnt/auto/shared` subdirectory, as `autofs` creates and deletes it dynamically.

```bash
sudo mkdir -p /mnt/auto
```

---

## Step 3: Configure the Master Map

You need to tell `autofs` to watch `/mnt/auto`, refer to `/etc/auto.shared` for the map details, and use a 5-minute (300 seconds) idle timeout.

1. If you forget the structure of the master map or how to specify a timeout, consult its manual page:
   ```bash
   man 5 autofs.master
   ```
   *Searching `/timeout` inside the man page reveals that options like `--timeout=300` are added at the end of the master map line.*
2. Edit `/etc/auto.master` and add the following line:
   ```text
   /mnt/auto  /etc/auto.shared  --timeout=300
   ```

---

## Step 4: Configure the Map File

Now, define how the `shared` subdirectory mounts.

1. If you forget how to write the indirect map file entries, look at its manual page:
   ```bash
   man 5 autofs
   ```
   *This documents the standard format:*
   ```text
   key [-options] location
   ```
2. Create and edit the `/etc/auto.shared` file, adding the following entry:
   ```text
   shared  -fstype=nfs,rw  data-001:/exports/shared
   ```
   *Here, `shared` is the key (creating `/mnt/auto/shared`), `-fstype=nfs,rw` are the mount options, and `data-001:/exports/shared` is the remote export source.*

---

## Step 5: Start the Service and Trigger the Mount

1. Restart `autofs` to load your new configuration files:
   ```bash
   sudo systemctl restart autofs
   ```
2. Access the directory to trigger the automatic mount:
   ```bash
   cd /mnt/auto/shared
   ```
3. Check the active mounts to confirm the NFS share was mounted on demand:
   ```bash
   mount | grep shared
   ```

---

## Step 6: Verify the Idle Timeout

1. Move out of the mount directory so it is no longer marked "in use":
   ```bash
   cd ~
   ```
2. Wait past the 5-minute timeout window (300 seconds):
   ```bash
   sleep 310
   ```
3. Check active mounts again. The directory should be unmounted automatically:
   ```bash
   mount | grep shared
   ```
   *No output should be returned once the timeout expires.*

---

## Verification

Confirm your configuration matches the rules:

```bash
# 1. Check master map reference and timeout
cat /etc/auto.master | grep auto.shared

# 2. Check indirect map configuration
cat /etc/auto.shared

# 3. Check service status
systemctl is-active autofs

# 4. Confirm no persistent fstab entry exists for the share
grep shared /etc/fstab
```
