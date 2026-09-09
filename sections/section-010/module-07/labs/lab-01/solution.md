# Solution Guide: Removable Media & the FAT32 Filesystem

This guide shows you how to format, label, and mount a FAT32 filesystem with correct user ownership.

---

## Step 1: Format the Disk as FAT32

Identify the disk, then format it, explicitly forcing the FAT32 variant and setting the label in one step:

```bash
lsblk
sudo mkfs.vfat -F 32 -n USBDATA /dev/disk/by-id/virtio-lab017-media
```

`-F 32` matters here: on a small disk, `mkfs.vfat` may otherwise default to FAT16, which is not what the task asks for.

---

## Step 2: Create the Mount Point

```bash
sudo mkdir -p /mnt/usbdata
```

---

## Step 3: Mount with Your Own Ownership

FAT32 stores no Unix ownership on disk, so it has to be supplied as mount options — `uid=`/`gid=` for who owns every file, `umask=` for the permission bits to clear:

```bash
sudo mount -o uid=$(id -u),gid=$(id -g),umask=022 /dev/disk/by-id/virtio-lab017-media /mnt/usbdata
```

`$(id -u)` / `$(id -g)` substitute your own numeric user and group IDs, so the mount reports every file as owned by you.

---

## Step 4: Prove It's Writable Without sudo

```bash
touch /mnt/usbdata/proof.txt
ls -l /mnt/usbdata/proof.txt
```

No `sudo` needed — the file is created successfully and shows up owned by your own user, confirming the mount options took effect.
