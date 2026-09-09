# Solution Guide: Software RAID Fundamentals

This guide shows you how to build a persistent RAID 5 array from three raw disks.

---

## Step 1: Identify the Raw Disks

```bash
lsblk
```

The three 1GB disks are `/dev/disk/by-id/virtio-lab033-a`, `-lab033-b`, and `-lab033-c` (commonly `/dev/vdb`, `/dev/vdc`, `/dev/vdd`).

---

## Step 2: Create the RAID 5 Array

```bash
sudo mdadm --create /dev/md0 --level=5 --raid-devices=3 \
  /dev/disk/by-id/virtio-lab033-a \
  /dev/disk/by-id/virtio-lab033-b \
  /dev/disk/by-id/virtio-lab033-c
```

Answer `y` at the "Continue creating array?" prompt (or pass `--run` to skip it). The array starts an initial resync; it is usable immediately, just slower until that finishes.

```bash
cat /proc/mdstat
sudo mdadm --detail /dev/md0
```

---

## Step 3: Format and Mount

Format **the array device**, never a member disk directly:

```bash
sudo mkfs.ext4 /dev/md0
sudo mkdir -p /mnt/raid-data
sudo mount /dev/md0 /mnt/raid-data
```

---

## Step 4: Make the Array Persistent

Record the array so it reassembles as `/dev/md0` (not a renamed `/dev/md127`) at boot, and refresh the initramfs so early boot knows about it too:

```bash
sudo mdadm --detail --scan
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
sudo update-initramfs -u
```

---

## Step 5: Add the fstab Entry

```bash
UUID=$(sudo blkid -s UUID -o value /dev/md0)
echo "UUID=$UUID  /mnt/raid-data  ext4  defaults,nofail  0  2" | sudo tee -a /etc/fstab
sudo mount -a
findmnt /mnt/raid-data
```

`findmnt --verify` can confirm the new entry has no errors before you'd trust it at a real reboot.
