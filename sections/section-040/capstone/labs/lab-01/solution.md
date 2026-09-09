# Solution Guide (Offline & Exam Friendly)

This step-by-step guide walks you through creating a swap file and swap partition, configuring their priorities, and making them persistent without relying on complex shell parsing commands.

---

## Step 1: Check Current Swap State

Verify that no swap is currently configured:
```bash
free -h
swapon --show
```
*`free -h` should show `0` for swap, and `swapon --show` should return no output.*

---

## Step 2: Create a 2G Swap File

We need to allocate a 2G file at `/swapfile`.

1. Try the faster allocation tool first:
   ```bash
   sudo fallocate -l 2G /swapfile
   ```
2. If `fallocate` fails (some filesystems do not support it), fall back to `dd`:
   ```bash
   sudo dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress
   ```

---

## Step 3: Secure the File Permissions

For security, the kernel refuses to use a swap file that has group-readable or world-readable permissions.

1. Set the permissions to root-only read/write (`600`):
   ```bash
   sudo chmod 600 /swapfile
   sudo chown root:root /swapfile
   ```
2. If you forget what permissions are required, run `man 8 swapon` and search for "swapfile" to read the warning about permissions.

---

## Step 4: Format and Activate the Swap File

1. Format the file as swap:
   ```bash
   sudo mkswap /swapfile
   ```
2. Activate the swap file:
   ```bash
   sudo swapon /swapfile
   ```
3. Verify that the swap file is active:
   ```bash
   swapon --show
   free -h
   ```

---

## Step 5: Make the Swap File Persistent

You must add the swap file to `/etc/fstab` so it persists across reboots.

1. If you forget the layout of the `/etc/fstab` file, run `man 5 fstab` to check the column formats.
2. Edit `/etc/fstab` and append the following row:
   ```text
   /swapfile  none  swap  sw  0  0
   ```
   *The fields are: path, mountpoint (`none` since swap is not part of the file tree), type (`swap`), mount option (`sw` or `defaults`), and zero/zero for dump/fsck.*

3. Test your entry. Deactivate swap, then activate all swap entries defined in `/etc/fstab`:
   ```bash
   sudo swapoff /swapfile
   sudo swapon -a
   swapon --show
   ```
   *If `/swapfile` appears in the list, your `/etc/fstab` entry is correct.*

---

## Step 6: Identify the Spare Swap Partition

Now, find the dedicated partition that has no filesystem format and no mountpoint.

1. List the available storage devices with details:
   ```bash
   lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT
   ```
2. Inspect the output. Look for a partition (`TYPE` = `part`) that has:
   - A blank `FSTYPE` column.
   - A blank `MOUNTPOINT` column.
3. Note the partition's path (for example, `/dev/vdb1` or `/dev/vdc1`).
   - *For the rest of this guide, we assume this partition is `/dev/vdX1`. Replace `/dev/vdX1` with your actual device path.*

---

## Step 7: Format and Activate the Partition

1. Format the partition as swap:
   ```bash
   sudo mkswap /dev/vdX1
   ```
2. Activate it:
   ```bash
   sudo swapon /dev/vdX1
   ```
3. Check the active swap devices:
   ```bash
   swapon --show
   ```
   *You should see both `/swapfile` and `/dev/vdX1` in the output.*

---

## Step 8: Configure Swap Priorities

You need to make the partition the primary swap area (`pri=10`) and the swap file the fallback area (`pri=5`).

1. If you forget how to specify priorities, run `swapon -h` or `man swapon` and search for "priority". You will see that the `-p` or `--priority` flag is used.
2. Deactivate both swap areas to reset their state:
   ```bash
   sudo swapoff /swapfile /dev/vdX1
   ```
3. Re-enable them with explicit priorities:
   ```bash
   sudo swapon -p 10 /dev/vdX1
   sudo swapon -p 5 /swapfile
   ```
4. Verify the priorities:
   ```bash
   swapon --show
   ```
   *Verify that the partition has priority `10` and `/swapfile` has priority `5`.*

---

## Step 9: Make the Priorities Persistent

To preserve these priorities after a reboot, update your `/etc/fstab` file. Always use the partition's UUID instead of its raw name to prevent naming drift.

1. Find the UUID of your partition:
   ```bash
   sudo blkid /dev/vdX1
   ```
   *Note the `UUID="..."` value in the output.*
2. Edit `/etc/fstab` and configure both entries with the `pri=` mount option:
   ```text
   /swapfile   none  swap  sw,pri=5    0  0
   UUID=<your-partition-uuid>  none  swap  sw,pri=10   0  0
   ```
   *Replace `<your-partition-uuid>` with the UUID you found in the previous step.*

---

## Final Verification

Check that the persistent config works correctly:

```bash
# 1. Turn off swap
sudo swapoff -a

# 2. Turn on all swap defined in fstab
sudo swapon -a

# 3. Check that priorities and sizes are correct
swapon --show
free -h
```
