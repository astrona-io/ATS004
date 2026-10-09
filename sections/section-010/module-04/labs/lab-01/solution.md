# Solution Walkthrough

This walkthrough repairs the damaged filesystem, labels it, and mounts it by UUID from `/etc/fstab`. Do the steps in order: the repair must happen while the filesystem is unmounted, before anything else touches it.

---

## Step 1: Find the disk

List the block devices with their filesystems:

```sh
lsblk -f
```

Look for the 2 GB disk with no mount point. It is usually `/dev/vdb`. To be sure, see where the stable path points:

```sh
ls -l /dev/disk/by-id/virtio-lab013-corrupt
```

The link ends with the kernel's name for the disk, such as `../../vdb`. The steps below use the stable path, so they work whatever the device name is.

---

## Step 2: Repair the filesystem

Never run `fsck` on a mounted filesystem. The disk is not mounted, so run the repair and answer "yes" to every fix with `-y`:

```sh
sudo fsck -y /dev/disk/by-id/virtio-lab013-corrupt
```

`fsck` calls `e2fsck` for ext4 and works through its five passes. Look for the lines where it reports and fixes problems. Run the same command once more: a repaired filesystem ends with `clean` and its counts of files and blocks.

If any files seem to be missing afterwards, they may be in `lost+found` at the top of the filesystem once it is mounted.

---

## Step 3: Give it a label

Set the label in the superblock:

```sh
sudo tune2fs -L RECOVERED_VOL /dev/disk/by-id/virtio-lab013-corrupt
```

---

## Step 4: Read the UUID

Show the label and the UUID:

```sh
sudo blkid /dev/disk/by-id/virtio-lab013-corrupt
```

Check that the line shows `LABEL="RECOVERED_VOL"` and `TYPE="ext4"`. Copy the value inside `UUID="..."`: a long string of letters and digits in five groups joined by hyphens. To print only the UUID, run:

```sh
sudo blkid -s UUID -o value /dev/disk/by-id/virtio-lab013-corrupt
```

---

## Step 5: Add the line to /etc/fstab

Create the mount point:

```sh
sudo mkdir -p /mnt/recovered
```

Open `/etc/fstab` in an editor:

```sh
sudo nano /etc/fstab
```

Add this line at the end, with your UUID in place of `<UUID>`. Write it without quotes, so the line starts with `UUID=` and the UUID itself:

```text
UUID=<UUID> /mnt/recovered ext4 defaults 0 2
```

Save the file and close the editor.

---

## Step 6: Mount from /etc/fstab

Check the file before you rely on it. A bad line in `/etc/fstab` can stop the machine at its next boot:

```sh
sudo findmnt --verify
```

Fix any error it reports for your line. Then mount everything in `/etc/fstab` that is not mounted yet:

```sh
sudo mount -a
```

---

## Step 7: Check what the grader checks

The grader looks at the live machine. Run the same checks yourself.

Something must be mounted at `/mnt/recovered`:

```sh
findmnt /mnt/recovered
df -h | grep /mnt/recovered
```

You should see the disk's device, such as `/dev/vdb`, with `ext4`.

The disk must carry the label `RECOVERED_VOL`:

```sh
sudo blkid -s LABEL -o value /dev/disk/by-id/virtio-lab013-corrupt
```

It should print `RECOVERED_VOL`.

`/etc/fstab` must have a line that starts with `UUID=` and the disk's UUID, on `/mnt/recovered`:

```sh
grep "^UUID=$(sudo blkid -s UUID -o value /dev/disk/by-id/virtio-lab013-corrupt)" /etc/fstab
```

It should print your line, ending in `/mnt/recovered ext4 defaults 0 2`.

When all three checks look right, send the mission for grading:

```sh
astrona submit -c sections/section-010/module-04/labs/lab-01
```
