# Creating Btrfs and Subvolumes

Btrfs is a filesystem like ext4, but it keeps one pool of space and lets you cut named shelves out of it. This part shows how you build the pool, look inside it, cut a shelf, and dock that shelf at its own hatch for good.

## The idea behind Btrfs

Before any command, here is the one idea that makes Btrfs different from ext4. This section explains it with a picture and then names the two words you need.

### Copy-on-write in plain words

When ext4 changes a file, it writes the new data over the old data. Btrfs never does that. It writes the new data to a free spot and then updates the cargo tag to point there. The old data stays untouched until nothing needs it any more. This is called **copy-on-write**.

In space terms, ext4 repaints a label on a crate in place. Btrfs prints a fresh label, sticks it on, and keeps the old one in the drawer until nobody asks for it. That drawer is the reason snapshots are cheap, as the next part shows.

### Subvolumes: shelves in one hold

A **subvolume** is a named shelf inside the filesystem. It looks like a normal directory, but you can mount it on its own, and you can photograph it on its own. All subvolumes share the free space of the one filesystem, so you never have to decide a size for each one.

## Building and inspecting the filesystem

Now you build a Btrfs filesystem. This section formats the disk, mounts it and reads its state with the Btrfs tools.

### See it in your playground

The playground installs the tools if they are missing, but you can check by hand. Then find the 2 GB disk, format it with the label `VAULT` and mount it:

<!-- astrona:playground:renew -->

```sh
command -v mkfs.btrfs
lsblk
sudo mkfs.btrfs -L VAULT /dev/disk/by-id/virtio-s010m10-a
sudo mkdir -p /mnt/vault
sudo mount /dev/disk/by-id/virtio-s010m10-a /mnt/vault
```

`mkfs.btrfs` prints a summary of what it built, and the command is done. `-L VAULT` writes the label, the hold's painted name. The mount needs no filesystem type: the kernel reads it from the disk.

Now read the state of the filesystem with three views:

```sh
sudo btrfs filesystem show /mnt/vault
sudo btrfs filesystem df /mnt/vault
sudo btrfs filesystem usage /mnt/vault
```

`show` lists the label, the UUID and each device in the pool. `df` shows how the space is split between data and metadata. `usage` gives a fuller report, including how much is still unallocated. The exact numbers depend on your disk, so read them on your own screen.

## Cutting a subvolume

A subvolume is the shelf you will actually use. This section creates one, lists it and mounts it on its own.

### See it in your playground

Create the subvolume `data` at the top of the filesystem and list it:

```sh
sudo btrfs subvolume create /mnt/vault/data
sudo btrfs subvolume list /mnt/vault
```

The list shows one line for `data`, with an ID and the path `data`. In `ls`, `/mnt/vault/data` looks like a plain directory. The top of the filesystem is subvolume 5 and always exists.

Next, unmount the whole filesystem and mount only the subvolume at `/srv/vault`. The `subvol=` option says which shelf to dock:

```sh
sudo umount /mnt/vault
sudo mkdir -p /srv/vault
sudo mount -o subvol=data /dev/disk/by-id/virtio-s010m10-a /srv/vault
findmnt /srv/vault
```

`findmnt` shows the device and the options, including `subvol=` with the name of the shelf. The ship now sees only the content of `data` at `/srv/vault`. The rest of the filesystem is not visible there.

## Making the subvolume mount persistent

A mount you typed by hand is gone after a launch. This section writes the logbook line that docks the subvolume again every time.

### See it in your playground

Get the UUID of the filesystem:

```sh
sudo blkid /dev/disk/by-id/virtio-s010m10-a
```

Add this line to the logbook, with the UUID from the output in place of `<UUID>`. Edit the file with `sudo nano /etc/fstab`:

```text
UUID=<UUID> /srv/vault btrfs subvol=data 0 0
```

Then unmount, and let the logbook do the mounting. `mount -a` mounts everything in `/etc/fstab` that is not mounted yet, so it proves the line works before a real launch:

```sh
sudo umount /srv/vault
sudo mount -a
findmnt /srv/vault
```

`findmnt` shows the subvolume mounted again, this time by the logbook line. The device is named by UUID, because `/dev/vdb` can change name between launches.

## Common pitfalls

> [!WARNING]
> - `mkfs.btrfs` erases the disk. Confirm the device with `lsblk` before you run it.
> - A subvolume is not a separate disk. If the filesystem is damaged, every subvolume in it is affected.
> - `-o subvol=data` and the fstab option `subvol=data` take the path of the subvolume inside the filesystem, not a path on the ship's corridor.
> - Use `UUID=` in `/etc/fstab`. Several subvolumes of one filesystem share the same UUID, so the `subvol=` option is what tells the lines apart.
