# Solution Walkthrough

Four moves: stop the mirror, assemble it again, mount it, and wipe the stray label. After each step you can run `astrona submit -c sections/section-030/module-04/labs/lab-03` to see what the grader still misses.

---

## Step 1: Unmount and stop the array

An array that is mounted or in use cannot be stopped, so undock it first:

```sh
sudo umount /mnt/raid
sudo mdadm --stop /dev/md0
cat /proc/mdstat
```

`mdadm --stop` shuts the array down and frees its disks. The array no longer appears in `/proc/mdstat`. The data is not lost: every member disk keeps a small label (the superblock) that says which array it belongs to.

---

## Step 2: Assemble it again

```sh
sudo mdadm --assemble /dev/md0 /dev/disk/by-id/virtio-lab030403-a /dev/disk/by-id/virtio-lab030403-b
cat /proc/mdstat
sudo mdadm --detail /dev/md0
```

`--assemble` reads the label on each named disk and starts the array that the labels describe. `--detail` shows `Raid Level : raid1`, a clean state and 2 active devices.

---

## Step 3: Mount it and check the data

```sh
sudo mount /dev/md0 /mnt/raid
cat /mnt/raid/manifest.txt
```

The file is there, so stopping and assembling lost nothing.

---

## Step 4: Wipe the stray label

```sh
sudo mdadm --examine /dev/disk/by-id/virtio-lab030403-c
cat /proc/mdstat
```

`--examine` reads the label on one disk. If it prints array details, the disk carries an old label. If `/proc/mdstat` lists an array that holds the disk (for example `md9` or `md127`), stop that array first, for example `sudo mdadm --stop /dev/md127`. Then erase the label and check:

```sh
sudo mdadm --zero-superblock /dev/disk/by-id/virtio-lab030403-c
sudo mdadm --examine /dev/disk/by-id/virtio-lab030403-c
```

The last command now says `No md superblock detected`. `--zero-superblock` works only on a disk that is not part of a running array, and it erases only the label, not the data. Run `astrona submit` for the final grade.
