# Solution Walkthrough

You format the blank disk as XFS, dock it for good through `/etc/fstab`, and run a dry-run repair check on the old disk while it stays undocked.

## Step 1: Find the disks

List the block devices and find the two 1 GB disks:

```bash
lsblk -f
```

The task gives the stable paths `/dev/disk/by-id/virtio-lab091-new` and `/dev/disk/by-id/virtio-lab091-old`. The old disk shows `xfs` and the label `OLDCARGO`. The new disk shows no filesystem. Use the stable paths so you never format the wrong disk.

## Step 2: Format the new disk

```bash
sudo mkfs.xfs -L NEWCARGO /dev/disk/by-id/virtio-lab091-new
```

If `mkfs.xfs` refuses because it sees a filesystem, you picked the wrong disk. Stop and check the path.

Send the first checkpoint:

```bash
astrona submit -c sections/section-010/module-09/labs/lab-01
```

The grader will still fail on later steps. That is normal while you are not done.

## Step 3: Create the mount point and read the UUID

```bash
sudo mkdir -p /srv/newcargo
sudo blkid -s UUID -o value /dev/disk/by-id/virtio-lab091-new
```

Write the printed UUID down. You need it in the next step.

## Step 4: Add the line to /etc/fstab

Replace `<UUID>` with the value from Step 3:

```bash
echo 'UUID=<UUID>  /srv/newcargo  xfs  defaults,noatime  0  0' | sudo tee -a /etc/fstab
```

## Step 5: Mount it from the logbook and verify

```bash
sudo findmnt --verify
sudo mount -a
findmnt /srv/newcargo
```

`findmnt` shows `xfs` with `noatime` in the options. Send the second checkpoint:

```bash
astrona submit -c sections/section-010/module-09/labs/lab-01
```

## Step 6: Dry-run the repair check on the old disk

The old disk is not mounted, so `xfs_repair` may look at it. `-n` means no changes. `2>&1` sends the messages the tool writes on its error stream into the same file:

```bash
sudo xfs_repair -n /dev/disk/by-id/virtio-lab091-old > /home/ubuntu/oldcargo-check.txt 2>&1
echo $?
cat /home/ubuntu/oldcargo-check.txt
```

The exit status is `0` for a clean filesystem. The file holds the phases the tool walked through.

## Step 7: Grade

```bash
astrona submit -c sections/section-010/module-09/labs/lab-01
```
