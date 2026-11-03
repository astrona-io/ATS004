# Solution Walkthrough

You format the disk as FAT32 with its label, mount it with your own user and group IDs, and prove that you can write without `sudo`. FAT32 stores no owner on the disk, so the mount options do all the ownership work.

## Step 1: Find the disk

List the block devices and find the blank 1 GB disk:

```bash
lsblk
```

The task gives the disk's stable path, `/dev/disk/by-id/virtio-lab017-media`. It points at the same disk as its short name (often `/dev/vdb`), so you can use the stable path in every command and never format the wrong disk.

## Step 2: Format the disk as FAT32 with the label

Force the FAT32 variant and set the label in one command:

```bash
sudo mkfs.vfat -F 32 -n USBDATA /dev/disk/by-id/virtio-lab017-media
```

`-F 32` matters here. On a small disk, `mkfs.vfat` may otherwise choose FAT16, which is not what the task asks for. `-n USBDATA` writes the volume label.

## Step 3: Create the mount point

```bash
sudo mkdir -p /mnt/usbdata
```

## Step 4: Mount with your own ownership

FAT32 stores no Unix owner on the disk, so you supply it as mount options. `uid=` and `gid=` say who owns every file, and `umask=` says which permission bits to remove:

```bash
sudo mount -o uid=$(id -u),gid=$(id -g),umask=022 /dev/disk/by-id/virtio-lab017-media /mnt/usbdata
```

Run this as the `ubuntu` user. `$(id -u)` and `$(id -g)` then put your own numeric user and group IDs into the options, so the kernel reports every file as yours.

## Step 5: Prove you can write without sudo

```bash
touch /mnt/usbdata/proof.txt
ls -l /mnt/usbdata/proof.txt
```

There is no `sudo` here. The file is created, and `ls -l` shows it owned by `ubuntu`. That proves the mount options took effect.

## Step 6: Check what the grader checks

Read the filesystem type and label, and the mount options:

```bash
sudo blkid /dev/disk/by-id/virtio-lab017-media
findmnt /mnt/usbdata
```

Look for `LABEL="USBDATA"` and `TYPE="vfat"` in the `blkid` line, and for `uid=` followed by your user ID in the `findmnt` options. Then send the mission for grading from your own computer:

```bash
astrona submit -c sections/section-010/module-07/labs/lab-01
```
