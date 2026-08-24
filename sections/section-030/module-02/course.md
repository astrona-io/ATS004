# Advanced LVM Operations

The true power of LVM is not abstracting storage; it is manipulating that storage while the system is under heavy load. If LVM basics are laying out the cubicles, advanced operations are dynamically sliding the cubicle walls back and forth without disturbing the workers actively typing at their desks.

These are high-stakes operations. A mistake here destroys data. You must understand exactly how the extents map to the hardware.

## Zero-Downtime Hardware Migration

Hard drives fail. Usually, they start throwing read errors or SMART warnings before they die completely. In a traditional setup, replacing a failing drive means scheduled downtime, tape backups, and data restoration.

With LVM, you migrate the data off the failing disk while applications are still writing to it.

If `/dev/sdb` is throwing errors, but it is part of your `data_pool` Volume Group, your first step is to add a healthy replacement disk to the pool.

```bash
pvcreate /dev/sdd
vgextend data_pool /dev/sdd
```

Now you have free, healthy extents in the pool. You command LVM to evacuate all used extents off the failing drive.

```bash
pvmove /dev/sdb
```

The `pvmove` command tracks every block. It copies the data from the failing `/dev/sdb` to the new `/dev/sdd`. If an application writes to a block during the copy, LVM intercepts the write, updates the new location, and continues. The filesystem mounted on top never notices the underlying physical hardware is changing out from under it.

Once `pvmove` finishes, `/dev/sdb` is completely empty of LVM data. You then remove it from the pool.

```bash
vgreduce data_pool /dev/sdb
```

Finally, you wipe the LVM header from the drive so it can be physically unplugged.

```bash
pvremove /dev/sdb
```

## Live Volume Expansion

When a filesystem fills up, LVM allows you to expand it on the fly. This is a two-step process: you must first enlarge the block device (the container), and then command the filesystem to expand into the newly available space.

First, you instruct LVM to assign more extents to the Logical Volume.

```bash
lvextend -L +20G /dev/data_pool/app_data
```

The `-L +20G` flag is critical. The `+` sign means "add 20 Gigabytes to the current size". If you omit the `+` sign, you are telling LVM to "make the absolute size exactly 20 Gigabytes". If the volume was 50G, omitting the `+` shrinks the volume, truncates the filesystem, and immediately destroys 30G of data. Always double-check your signs.

The block device is now larger, but the filesystem sitting inside it doesn't know that yet. You must resize the filesystem.

If the filesystem is `ext4`, use `resize2fs`.

```bash
resize2fs /dev/data_pool/app_data
```

If the filesystem is `XFS`, the command is different and it requires the mount point, not the device path.

```bash
xfs_growfs /mnt/app-data
```

Both commands will recognize the new boundary of the block device and instantly expand the filesystem structure to use the new space. The applications writing to the disk experience zero interruption.

## Self-Check and Verification

To prove you can handle live LVM maintenance:

1. Identify a Volume Group with an active, mounted Logical Volume spanning at least one physical disk.
2. Add a new physical disk to the machine and extend the Volume Group using `vgextend`.
3. Perform a live evacuation of the original disk using `pvmove`. Watch the progress until completion.
4. Safely remove the evacuated disk from the Volume Group using `vgreduce`.
5. Add 5GB of capacity to the active Logical Volume using `lvextend -L +5G`.
6. Run `df -h` to note the current filesystem size, execute `resize2fs` (or `xfs_growfs`), and verify the filesystem reflects the new capacity instantly.
