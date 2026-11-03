# Solution Walkthrough

This capstone joins three skills: preparing a raw disk, reading disk usage, and freeing a disk that a running process holds. You only need basic commands and careful reading of their output.

## Step 1: Identify the raw disk

You need the disk that has no partitions and is not mounted. List all storage devices:

```bash
lsblk
```

Look for a device (such as `vdb` or `vdc`) that:

- has no child partitions underneath it (no `vdb1`), and
- has an empty `MOUNTPOINTS` column.

Then make sure it has no filesystem:

```bash
sudo blkid
```

`blkid` lists every device that carries a filesystem. A disk that `lsblk` shows but `blkid` does not is raw. Note its name, for example `/dev/vdb`. The extra disks do not always get the same letters, so read the name from your own output.

## Step 2: Format the disk

Format the raw disk with ext4. Replace `/dev/vdX` with the name you found:

```bash
sudo mkfs.ext4 /dev/vdX
```

## Step 3: Mount the disk

Create the mount point and mount the new filesystem there:

```bash
sudo mkdir -p /mnt/backup-black
sudo mount /dev/vdX /mnt/backup-black
```

## Step 4: Create the marker file

Create the empty `completed` file:

```bash
sudo touch /mnt/backup-black/completed
```

## Step 5: Find the disk with the higher usage

Show the space used on every mounted filesystem:

```bash
df -h
```

Find the rows for `/mnt/backup-blue` and `/mnt/backup-red` in the "Mounted on" column, and compare their **Used** or **Use%** columns. For example, if `/mnt/backup-blue` uses `2.1G` and `/mnt/backup-red` uses `980M`, then `/mnt/backup-blue` is the busier disk.

## Step 6: Empty the trash folder

Empty the `.trash` folder on the busier disk by deleting it and creating it again. If the busier disk is `/mnt/backup-blue`:

```bash
sudo rm -rf /mnt/backup-blue/.trash
sudo mkdir /mnt/backup-blue/.trash
```

The grader wants the folder to exist and be empty, so do not skip the `mkdir`.

## Step 7: Compare the memory use of the two processes

List the two processes:

```bash
ps aux | grep dark-matter
```

Read these columns for `dark-matter-v1` and `dark-matter-v2`:

- **PID** (column 2): the process ID, the crew member's badge number.
- **VSZ** (column 5) and **RSS** (column 6): the virtual and the resident memory size.

Note the PID of the process with the larger numbers.

## Step 8: Find the process's executable file

The command column of `ps aux` often shows the full path, for example `/mnt/backup-red/bin/dark-matter-v2`. If it only shows the name, ask the kernel where the running program came from:

```bash
ls -l /proc/<PID>/exe
```

Replace `<PID>` with the process ID from Step 7. The link points at the executable file, and the start of that path tells you which mounted disk holds it.

## Step 9: Stop the process and unmount its disk

If the executable is `/mnt/backup-red/bin/dark-matter-v2`, it lives on the `/mnt/backup-red` filesystem. `df -h` shows which device is mounted there.

Stop the process first. While it runs, the kernel keeps the disk busy and `umount` fails with `target is busy`. The process runs as a systemd service, so stop the service:

```bash
sudo systemctl stop dark-matter-v2
```

You could also stop the process directly by its PID with `sudo kill <PID>`, and use `sudo kill -9 <PID>` only if it does not stop. Stopping the service is the cleaner way: systemd then knows the service was stopped on purpose. Then unmount the disk:

```bash
sudo umount /mnt/backup-red
```

## Step 10: Check what the grader checks

```bash
findmnt /mnt/backup-black
ls -l /mnt/backup-black/completed
sudo ls -A /mnt/backup-blue/.trash
findmnt /mnt/backup-red
```

Look for an `ext4` row for `/mnt/backup-black`, a `completed` file of size `0`, no files listed for the `.trash` folder, and no output at all for `/mnt/backup-red` (it is no longer mounted). Then send the capstone for grading from your own computer:

```bash
astrona submit -c sections/section-010/capstone/labs/lab-01
```
