# Solution Guide: Backing Up & Cloning Storage Devices

This guide shows you how to clone a whole disk with `dd` and verify the result.

---

## Step 1: Identify the Two Disks

```bash
lsblk
```

The source disk (with data on it) and the clone disk (blank) are resolvable via their `serial` (set in `config.yaml`) through the kernel's stable `/dev/disk/by-id/virtio-<serial>` path:

```bash
SOURCE=/dev/disk/by-id/virtio-lab018-source
CLONE=/dev/disk/by-id/virtio-lab018-clone
```

---

## Step 2: Clone the Source Disk onto the Clone Disk

```bash
sudo dd if="$SOURCE" of="$CLONE" bs=4M status=progress
```

`if=` is the disk being read (the source); `of=` is the disk being overwritten (the clone). Double-check this direction against the disk names above before running it — `dd` overwrites `of=` immediately, with no confirmation prompt.

---

## Step 3: Verify the Clone Matches the Source

```bash
sudo sha256sum "$SOURCE" "$CLONE"
```

Both checksums should be identical — confirming the clone is a byte-for-byte match of the source, not just "the command didn't error."
