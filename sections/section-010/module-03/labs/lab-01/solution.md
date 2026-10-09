# Solution Walkthrough

You lock the disk first, then open it, then build a filesystem on the opened device and mount it. The order matters: the filesystem goes on the `/dev/mapper/` device, never on the raw disk.

---

## Step 1: Find the raw disk

List the disks and look for the 2 GB one with no partitions and no mount point:

```sh
lsblk
```

It is usually `/dev/vdb`. The steps below assume `/dev/vdb`. To be sure, check that the disk's serial number link points to it:

```sh
ls -l /dev/disk/by-id/virtio-lab012-raw
```

The link should end in `../../vdb`. If it points to another name, use that name in every step below.

---

## Step 2: Lock the disk with LUKS

Create the LUKS container with the passphrase `securepassword123`:

```sh
echo "securepassword123" | sudo cryptsetup luksFormat /dev/vdb
```

Because the passphrase comes through a pipe and not from your keyboard, `cryptsetup` reads it from the pipe and does not stop to ask questions.

If you type the command without the pipe (`sudo cryptsetup luksFormat /dev/vdb`), it asks you to confirm first. Type `YES` in capital letters, then enter `securepassword123` twice:

```text
WARNING!
========
This will overwrite data on /dev/vdb irrevocably.

Are you sure? (Type 'yes' in capital letters): YES
Enter passphrase for /dev/vdb:
Verify passphrase:
```

---

## Step 3: Open the encrypted volume

Open the disk and map it to `/dev/mapper/secure_volume`:

```sh
echo "securepassword123" | sudo cryptsetup open /dev/vdb secure_volume
```

The kernel's device mapper now shows the unscrambled device. Check that it is there:

```sh
ls -l /dev/mapper/secure_volume
```

You should see a link from `/dev/mapper/secure_volume` to a `../dm-` device, for example `../dm-0`.

---

## Step 4: Format the mapped device

Create the ext4 filesystem on the mapped device, not on `/dev/vdb`:

```sh
sudo mkfs.ext4 /dev/mapper/secure_volume
```

Formatting `/dev/vdb` here would destroy the LUKS header you just made.

---

## Step 5: Mount it and create the marker file

Create the mount point, mount the volume and create the empty marker file:

```sh
sudo mkdir -p /mnt/secure-data
sudo mount /dev/mapper/secure_volume /mnt/secure-data
sudo touch /mnt/secure-data/sealed
```

---

## Step 6: Check your work and submit

Check what the grader checks: `/dev/mapper/secure_volume` is mounted at `/mnt/secure-data`, the filesystem is ext4, the marker file exists, and `cryptsetup` reports the mapping as active.

```sh
findmnt /mnt/secure-data
ls -l /mnt/secure-data/sealed
sudo cryptsetup status secure_volume
```

`findmnt` should show `/dev/mapper/secure_volume` as the source and `ext4` as the filesystem type. `ls -l` shows the empty `sealed` file. `cryptsetup status` should say that `/dev/mapper/secure_volume` is active and in use, with type `LUKS2`.

When all three look right, send it for grading:

```sh
astrona submit -c sections/section-010/module-03/labs/lab-01
```
