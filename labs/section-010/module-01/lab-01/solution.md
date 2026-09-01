# Solution Walkthrough

Follow these steps on the terminal to prepare, format, and mount the disk:

---

## Step 1: Identify the Raw Disk
Run `lsblk` to view all attached block storage:
```bash
lsblk
```
You will see a raw disk of size `1G` (usually `/dev/vdb` or similar) with no partition numbers underneath and no mount point. Confirm it has no filesystem using `blkid`:
```bash
sudo blkid
```
The raw disk will not appear in the `blkid` list, confirming it is blank.

---

## Step 2: Format the Disk with ext4
Format the identified raw disk path (e.g., `/dev/vdb`):
```bash
sudo mkfs.ext4 /dev/vdb
```

---

## Step 3: Mount the Disk
1.  Create the target mount point folder:
    ```bash
    sudo mkdir -p /mnt/backup-black
    ```
2.  Mount the formatted device there:
    ```bash
    sudo mount /dev/vdb /mnt/backup-black
    ```

---

## Step 4: Create the Marker File
Create the required empty marker file:
```bash
sudo touch /mnt/backup-black/completed
```

---

## Step 5: Verify Your Configuration
Confirm the disk capacity is active and mounted:
```bash
df -h | grep backup-black
```
And check the file exists:
```bash
ls -l /mnt/backup-black/completed
```
Once verified, run the local validation suite to pass the lab!
