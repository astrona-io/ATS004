# Mounting FAT32 & Its Unix-less Quirks

A FAT32 filesystem stores no owner, no group and no permission bits, only a file name and a chain of blocks. This part shows what that means the moment you mount one: with no options, every file looks as if it belongs to `root`, and no normal user can write to it. You learn how to fix that, and you meet the other hard limit of FAT32: the largest file it can hold.

## Ownership that does not exist on the disk

On ext4, the owner of each file is written on the disk. On FAT32 it is not, so someone else has to supply it. This section shows who does that, and with which mount options.

### The kernel reports what you tell it

When you mount an ext4 filesystem, the kernel reads each file's owner and permissions from that file's inode, its cargo tag. FAT32 has no inode and no owner field, so there is nothing to read. Instead, the kernel's `vfat` driver must be *told* which ownership to report for every file. You tell it with **mount options**, and they apply to the whole filesystem at once:

- **`uid=<N>`**: the numeric user ID that every file should appear to be owned by. This is the crew member's number on the crew roster.
- **`gid=<N>`**: the numeric group ID that every file should appear to be owned by (the rank on the roster).
- **`umask=<mode>`**: the permission bits to *remove*. It means the same as a shell umask, but it is applied to every file at mount time, because no file stores its own mode.

If you mount a FAT32 filesystem without any of these options, the kernel uses `uid=0,gid=0`. Every file then shows up as owned by `root`, and a normal user gets "Permission denied" when writing, even though nothing on the disk ever recorded a permission.

### See it in action

On a machine with a FAT32 disk at `/dev/vdb`, mount the disk once with no options, try to write as yourself, then mount it again with your own user and group IDs:

```sh
sudo mkdir -p /mnt/usbdata
sudo mount /dev/vdb /mnt/usbdata
ls -ld /mnt/usbdata
touch /mnt/usbdata/test.txt
sudo umount /mnt/usbdata
sudo mount -o uid=$(id -u),gid=$(id -g),umask=022 /dev/vdb /mnt/usbdata
ls -ld /mnt/usbdata
touch /mnt/usbdata/test.txt && echo "write ok"
```

Expect something like:

```text
drwxr-xr-x 2 root root 16384 ... /mnt/usbdata
touch: cannot touch '/mnt/usbdata/test.txt': Permission denied

drwxr-xr-x 2 ubuntu ubuntu 16384 ... /mnt/usbdata
write ok
```

The device is the same and so is the data. The only change between the two mounts is which ownership the kernel was told to *report*. `$(id -u)` and `$(id -g)` put your own numeric user and group IDs into the mount options. That is the normal way to mount removable media as "yours".

## The 4 GiB file that will not copy

FAT32 has a second limit that has nothing to do with free space. This section explains where it comes from and how it looks when you hit it.

### A size field with a ceiling

FAT32 stores each file's size in a 32-bit field. The largest number that field can hold is 4,294,967,295 bytes, just under 4 GiB. This is not a soft limit or a tip for speed. It is the largest size the format can write down for one file.

Copy anything bigger, such as a Linux installer image, a virtual machine disk or a long video, and the copy runs for a while. Then it fails with a "File too large" error, even on a nearly empty drive. The format stopped the copy, not the free space.

### See the limit

Check the free space, then ask for a file larger than 4 GiB:

```sh
df -h /mnt/usbdata
fallocate -l 4200M /mnt/usbdata/toobig.bin
```

Expect something like:

```text
Filesystem      Size  Used Avail Use% Mounted on
/dev/vdb        974M   16K  974M   1% /mnt/usbdata

fallocate: fallocate failed: File too large
```

The example disk is only about 1 GB, so here the space would run out as well. But the same "File too large" error appears on a nearly empty FAT32 drive of several terabytes the moment a single file goes over 4 GiB. That is the case to remember.

**exFAT** is the newer format from Microsoft built to remove this limit. It still stores no Unix permissions. This course does not use it hands-on, but it is the format to choose when you need to share between operating systems *and* store files larger than 4 GiB.

## Where FAT32 belongs

FAT32 is the right choice for one job only: removable media that must work unchanged on Windows, macOS and Linux. Think of a USB installer, a camera card or a drive for a firmware update.

It is never the right choice for a Linux system disk or for any data disk that needs real owners, several users with different access, or files close to 4 GiB. That is a job for ext4 or XFS.

## Common pitfalls

> [!WARNING]
> - **Mounting without `uid=` and `gid=`.** Every file looks owned by `root`, and a normal user's writes fail with "Permission denied", even though nothing on the disk restricts them.
> - **Running `chmod` or `chown` on a FAT32 file and expecting it to last.** There is no permission bit on the disk to change. The command either fails or does nothing, depending on the mount options. On FAT32, ownership is set at mount time for the whole filesystem, not per file.
> - **Copying a file near 4 GiB without checking first.** A copy that runs for minutes and then fails wastes real time. Check the source with `ls -lh` before a long copy onto FAT32.
> - **Using FAT32 for a data disk with several Linux users.** With no real ownership, every user sees every file as owned by whatever `uid=` and `gid=` the mount says. You cannot separate users on one FAT32 disk the way ext4 or XFS permissions can.

> *Every FAT32 quirk comes from one cause: the filesystem stores no owner, no permission bits, and only a 32-bit size for each file.*

## Your mission: FAT32 Removable Media

You can now format a disk as FAT32 with a label and mount it so that your own user owns the files. The mission asks you to turn a blank disk into a USB-style drive that the `ubuntu` user can write to without `sudo`.

Start the mission and connect to its machine:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-010/module-07/labs/lab-01
astrona ssh ats-004-lab-017
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-07/labs/lab-01
```

When the mission is done, remove it:

```sh
astrona destroy ats-004-lab-017
```
