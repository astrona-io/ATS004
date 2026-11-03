# Solution Walkthrough

You clone one whole disk onto another with `dd`, then prove the copy is exact. The direction of the copy is the one detail that can destroy data, so you check it before you run anything.

## Step 1: Identify the two disks

List the block devices:

```bash
lsblk
```

You see two spare 1 GB disks next to the system disk. Each has a serial number set in the lab, so the kernel also gives it a stable path under `/dev/disk/by-id/virtio-<serial>`. Store the two paths in readable variables:

```bash
SOURCE=/dev/disk/by-id/virtio-lab018-source
CLONE=/dev/disk/by-id/virtio-lab018-clone
```

Using these stable paths means you never depend on which disk became `/dev/vdb` and which became `/dev/vdc`.

## Step 2: Clone the source disk onto the clone disk

```bash
sudo dd if="$SOURCE" of="$CLONE" bs=4M status=progress
```

`if=` is the disk being read (the source). `of=` is the disk being overwritten (the clone). Check this direction against the variable names before you press Enter: `dd` overwrites `of=` at once, with no question.

## Step 3: Verify the clone matches the source

```bash
sudo sha256sum "$SOURCE" "$CLONE"
```

Both lines must show the same checksum. That proves the clone is a byte-for-byte match of the source, not only that the command ran without an error.

## Step 4: Check what the grader checks

The grader compares the disks with `cmp`, which prints nothing when they match. You can run the same check:

```bash
sudo cmp "$SOURCE" "$CLONE" && echo "identical"
```

Because the copy is exact, the clone also carries the source's label, `SOURCEVOL`, and its `hello.txt` file. `sudo blkid "$CLONE"` shows the label. Then send the mission for grading from your own computer:

```bash
astrona submit -c sections/section-010/module-08/labs/lab-01
```
