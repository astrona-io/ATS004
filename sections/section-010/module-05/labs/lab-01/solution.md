# Solution Walkthrough

You format the raw disk, write one `UUID=` line into `/etc/fstab` (the ship's logbook of holds to dock at every launch), mount it, and check the file before you would ever reboot. The grader checks the live machine: the line in the file, the real UUID of the disk, what is mounted, and what `findmnt --verify` says.

---

## Step 1: Identify and format the disk

List the disks. The new one is an empty cargo hold: it has no filesystem and no mount point.

```sh
lsblk
```

Look for a 1 GB disk with no children and nothing in the `MOUNTPOINTS` column. The task names it by its stable path, `/dev/disk/by-id/virtio-lab015-data1`, so use that path and you cannot pick the wrong disk.

Build the shelves: format it `ext4` with the label `APPDATA` (its painted name):

```sh
sudo mkfs.ext4 -L APPDATA /dev/disk/by-id/virtio-lab015-data1
```

`mkfs.ext4` also writes a new UUID, the hold's serial number, into the filesystem. You need that value in Step 3.

---

## Step 2: Create the mount point

The mount point is the hatch the hold docks to. `mount -a` fails if it does not exist:

```sh
sudo mkdir -p /mnt/appdata
```

---

## Step 3: Get the UUID

Read the UUID into a shell variable, and print it:

```sh
UUID=$(sudo blkid -s UUID -o value /dev/disk/by-id/virtio-lab015-data1)
echo "$UUID"
```

You should see one long ID made of letters, digits and dashes. If the line is empty, the disk is not formatted yet: go back to Step 1.

---

## Step 4: Add the fstab entry

Append one line keyed by `UUID=`. Each value has a reason:

- `nofail`: a missing disk never blocks the boot.
- `noatime`: skip the access-time write on every read.
- `dump` = `0`: the old backup tool is not used.
- `pass` = `2`: a local filesystem that is not root, checked by `fsck` after root.

```sh
echo "UUID=$UUID  /mnt/appdata  ext4  defaults,nofail,noatime  0  2" | sudo tee -a /etc/fstab
```

`tee` prints the line it added. Check that it shows the real UUID and not an empty `UUID=`. If the shell variable was lost (for example, in a new terminal), run Step 3 again first.

---

## Step 5: Apply and verify

Mount everything in the file that is not mounted yet, then look at the result:

```sh
sudo mount -a
findmnt /mnt/appdata
```

`findmnt` should show `/mnt/appdata` with an ext4 filesystem from the new disk. If `mount -a` prints an error, read it: it names the line that failed.

Check the whole table is safe before you would trust it at boot:

```sh
sudo findmnt --verify
```

No `[E]` lines should appear for the new entry.

---

## Step 6: Check what the grader checks

The grader reads the `/mnt/appdata` line in `/etc/fstab`, compares it with the disk, and looks at the live mount. Run the same checks yourself:

```sh
grep /mnt/appdata /etc/fstab
sudo blkid -s UUID -o value /dev/disk/by-id/virtio-lab015-data1
findmnt -no SOURCE,FSTYPE,OPTIONS /mnt/appdata
sudo findmnt --verify
```

Look for these results:

- The fstab line starts with `UUID=` and that UUID is the same as the one `blkid` prints.
- Its options include `nofail`, the fifth field is `0`, and the sixth field is `2`.
- Something is mounted at `/mnt/appdata`, its type is `ext4`, and its live options include `nofail`.
- `findmnt --verify` shows no `[E]` line for `/mnt/appdata`.

Then send it for grading:

```sh
astrona submit -c sections/section-010/module-05/labs/lab-01
```
