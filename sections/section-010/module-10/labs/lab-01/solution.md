# Solution Walkthrough

You format the disk as Btrfs, cut a subvolume, mount it persistently by UUID, add a file and take a read-only snapshot. After each step you can send the mission for grading with `astrona submit` from your own computer, and read what still fails.

## Step 1: Find the disk and check the tools

```bash
lsblk
command -v mkfs.btrfs
```

The task gives the stable path `/dev/disk/by-id/virtio-lab091-btrfs`. It points at the same disk as its short name, so use the stable path in every command and never format the wrong disk. The setup installs `btrfs-progs`, so `command -v` prints a path.

## Step 2: Format the disk with the label

```bash
sudo mkfs.btrfs -L VAULT /dev/disk/by-id/virtio-lab091-btrfs
```

`-L VAULT` writes the label. Grading now would still fail, because the later steps are missing.

## Step 3: Create the subvolume

Mount the top of the filesystem on a scratch mount point, then create the subvolume there:

```bash
sudo mkdir -p /mnt/vault-top
sudo mount /dev/disk/by-id/virtio-lab091-btrfs /mnt/vault-top
sudo btrfs subvolume create /mnt/vault-top/data
sudo btrfs subvolume list /mnt/vault-top
```

The list shows one line for `data`.

## Step 4: Mount the subvolume persistently by UUID

Read the UUID:

```bash
sudo blkid /dev/disk/by-id/virtio-lab091-btrfs
```

Create the mount point and add this line to `/etc/fstab` with `sudo nano /etc/fstab`, using the UUID from the output in place of `<UUID>`:

```text
UUID=<UUID> /srv/vault btrfs subvol=data 0 0
```

Then mount it from the logbook and check it:

```bash
sudo mkdir -p /srv/vault
sudo mount -a
findmnt /srv/vault
```

`findmnt` shows the options with `subvol=` and the name `data`.

## Step 5: Add the file and take the snapshot

```bash
echo "cargo list" | sudo tee /srv/vault/cargo.txt
sudo btrfs subvolume snapshot -r /mnt/vault-top/data /mnt/vault-top/data-snapshot
sudo btrfs subvolume list /mnt/vault-top
```

The list now shows `data` and `data-snapshot`. The `-r` option makes the snapshot read-only.

## Step 6: Send it for grading

```bash
astrona submit -c sections/section-010/module-10/labs/lab-01
```
