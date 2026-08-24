# Solution Guide: Partitioning Raw Storage

This guide explains how to partition a raw block device using a GPT label.

---

## Step 1: Identify the Raw Disk

List all block devices to identify the newly added 2GB drive:
```bash
lsblk
```
Identify the drive without child partitions or mountpoints (for example, `/dev/vdb`). You can verify its serial or symlink path using:
```bash
ls -l /dev/disk/by-id/virtio-lab011-raw
```

---

## Step 2: Initialize GPT Label

Use `parted` to write a GPT partition table to the disk:
```bash
sudo parted /dev/vdb mklabel gpt
```
*(Replace `/dev/vdb` with your identified device if different)*

---

## Step 3: Create the Partition

Create a primary partition starting at 1MiB (which aligns to sector 2048) and ending at 1GiB:
```bash
sudo parted /dev/vdb mkpart primary ext4 1MiB 1GiB
```

---

## Step 4: Verify the Layout

Verify that the partition table is GPT and the partition is correctly aligned:
```bash
sudo parted /dev/vdb print
```
The output should show `Partition Table: gpt` and list a single partition of approximately 1GB starting at 1049kB (1MiB).
