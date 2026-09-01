# Solution Guide (Offline & Exam Friendly)

This guide shows you how to solve the lab using basic Linux commands and visual inspection. You do not need to memorize complex scripts or obscure command arguments.

---

## Step 1: Identify the Raw Disk

You need to find a disk that has no partitions and is not mounted.

1. List all available storage devices:
   ```bash
   lsblk
   ```
2. Look at the output. You are looking for a device (like `vdb` or `vdc`) that:
   - Does not have any child partitions (e.g., no `vdb1` underneath it).
   - Has a blank `MOUNTPOINT` column.
   
3. Verify that the disk is unformatted. Run:
   ```bash
   sudo blkid
   ```
   This command lists all formatted disks. Any disk listed in `lsblk` but **not** in `blkid` is raw and unformatted. Note this device name (for example, `/dev/vdb`).

---

## Step 2: Format the Disk

Format your raw disk with the `ext4` filesystem. Replace `/dev/vdX` with your raw disk name:

```bash
sudo mkfs.ext4 /dev/vdX
```

---

## Step 3: Mount the Disk

1. Create the mount directory:
   ```bash
   sudo mkdir -p /mnt/backup-black
   ```
2. Mount the formatted disk there:
   ```bash
   sudo mount /dev/vdX /mnt/backup-black
   ```

---

## Step 4: Create the Marker File

Create the required empty `completed` file:

```bash
sudo touch /mnt/backup-black/completed
```

---

## Step 5: Find the Disk with Higher Usage

1. Check disk space usage for all mounted filesystems:
   ```bash
   df -h
   ```
2. Find the rows for `/mnt/backup-blue` and `/mnt/backup-red` in the "Mounted on" column.
3. Compare their **Used** or **Use%** columns. Note which one has higher usage.
   - For example, if `/mnt/backup-blue` uses `2.1G` and `/mnt/backup-red` uses `980M`, then `/mnt/backup-blue` is the disk with higher usage.

---

## Step 6: Empty the Trash Folder

To empty the `.trash` directory on the busier disk, delete the folder and recreate it. Assuming the busier disk is `/mnt/backup-blue`:

```bash
sudo rm -rf /mnt/backup-blue/.trash
sudo mkdir /mnt/backup-blue/.trash
```

---

## Step 7: Compare Process Memory Usage

Find which of the two running processes (`dark-matter-v1` or `dark-matter-v2`) consumes more memory.

1. List the processes:
   ```bash
   ps aux | grep dark-matter
   ```
2. Look at the columns in the output:
   - **PID** (Column 2): Process ID.
   - **VSZ** (Column 5) or **RSS** (Column 6): Memory size columns.
3. Compare the values for `dark-matter-v1` and `dark-matter-v2`. Note the PID of the one with larger memory numbers (this is usually `dark-matter-v2`).

---

## Step 8: Locate the Process Executable Path

Find the absolute path where the high-memory process is running from.

- **Method A:** Look at the command column output of the `ps aux | grep dark-matter` command. The full path is often shown there (e.g., `/mnt/backup-red/bin/dark-matter-v2`).
- **Method B:** If the command column only shows the binary name, run:
   ```bash
   ls -l /proc/<PID>/exe
   ```
   Replace `<PID>` with the actual process ID from Step 7. The output shows where the symbolic link points.

---

## Step 9: Identify and Unmount the Disk Backing the Executable

Based on the executable path (e.g., `/mnt/backup-red/bin/dark-matter-v2`), we can see it is on the `/mnt/backup-red` filesystem.

1. Find the device mounted at `/mnt/backup-red`:
   ```bash
   df -h
   ```
   Look for `/mnt/backup-red` in the "Mounted on" column and note its device (e.g., `/dev/vdc`).

2. Stop the process first, or the unmount command will fail with a `target is busy` error:
   ```bash
   sudo systemctl stop dark-matter-v2
   ```
   *(Or kill the process directly using its PID: `sudo kill -9 <PID>`)*

3. Unmount the disk:
   ```bash
   sudo umount /mnt/backup-red
   ```

---

## Quick Verification

Confirm everything is done correctly:

```bash
# 1. Check if backup-black is mounted and formatted with ext4
mount | grep backup-black

# 2. Check if the completed file exists
ls -l /mnt/backup-black/completed

# 3. Check if the .trash folder is empty (should return no files)
sudo ls -A /mnt/backup-blue/.trash

# 4. Check if the target disk is unmounted (should print nothing)
mount | grep backup-red
```
