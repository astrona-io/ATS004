# Solution Walkthrough

Four moves, in this order: find the raw disk, format it, mount it, and leave the marker file. The last step checks the machine the same way the grader does.

---

## Step 1: Identify the raw disk

List every disk the kernel sees:

```sh
lsblk
```

Look for a disk of size `1G`, usually `/dev/vdb`, with no partitions under it and no mount point. This mission's disk is also reachable as `/dev/disk/by-id/virtio-lab014-scratch`.

Now confirm that it has no filesystem:

```sh
sudo blkid
```

The raw disk does not appear in the `blkid` list. `blkid` only lists devices that carry a filesystem header, so a missing line means the disk is blank and safe to format.

---

## Step 2: Format the disk with ext4

Format the disk you identified. The example uses `/dev/vdb`; use your own device name if it differs:

```sh
sudo mkfs.ext4 /dev/vdb
```

`mkfs.ext4` prints a few lines about blocks, inodes and the journal, and ends with `done`. Run `sudo blkid /dev/vdb` afterwards: it should now show a UUID and `TYPE="ext4"`.

---

## Step 3: Mount the disk

Create the mount point:

```sh
sudo mkdir -p /mnt/backup-black
```

Mount the formatted disk on it:

```sh
sudo mount /dev/vdb /mnt/backup-black
```

`mount` prints nothing when it works.

---

## Step 4: Create the marker file

Create the empty marker file on the mounted disk:

```sh
sudo touch /mnt/backup-black/completed
```

---

## Step 5: Check your work and submit

Check what the grader checks: something is mounted at `/mnt/backup-black`, it is ext4, and the marker file is there.

```sh
findmnt /mnt/backup-black
df -h | grep backup-black
ls -l /mnt/backup-black/completed
```

`findmnt` should show your disk as the source and `ext4` as the filesystem type. `df -h` lists the disk against `/mnt/backup-black`, and `ls -l` shows the empty `completed` file.

When all three look right, send it for grading:

```sh
astrona submit -c sections/section-010/module-01/labs/lab-01
```
