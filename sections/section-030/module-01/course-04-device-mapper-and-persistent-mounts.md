# How an LV Becomes a Device, and Stays Mounted

An LV looks like a plain disk to the filesystem, but it is only a list of extents. This page shows how the kernel turns that list into a device, how to read the list yourself, and how to make the mount come back after a reboot.

## From extent list to device

When you run `lvcreate`, LVM writes the extent list into the metadata area of the disk. The kernel part that reads the list is called **device-mapper**. It builds a virtual block device under `/dev/mapper/` and forwards every read and write to the right physical extent.

> As an analogy: device-mapper is the cargo master of the pool. A crew member asks for "crate 7 of the water supply". The cargo master looks up the manifest and fetches the crate from the real slot on whichever hold it sits in. The crew never learns which hold it was. The analogy breaks down because device-mapper only translates positions, it never stores cargo itself.

LVM names the device `<vg>-<lv>`. A dash inside the VG or LV name is doubled, so `my-vg` with `my-lv` becomes `my--vg-my--lv`. The paths `/dev/<vg>/<lv>` and `/dev/mapper/<vg>-<lv>` are two names for the same device.

### See it in your playground

On a fresh playground the three disks are raw. Build the pool, the volume, and a mounted filesystem first:

<!-- astrona:playground:renew -->

```sh
sudo pvcreate /dev/vdc /dev/vdd
sudo vgcreate company_storage /dev/vdc /dev/vdd
sudo lvcreate -n shared_documents -L 200M company_storage
sudo mkfs.ext4 /dev/company_storage/shared_documents
sudo mkdir -p /mnt/shared_documents
sudo mount /dev/company_storage/shared_documents /mnt/shared_documents
```

Now read the extent list three ways. Each command shows the same fact at a different level:

```sh
sudo lvdisplay -m /dev/company_storage/shared_documents
sudo lvs -o +seg_pe_ranges company_storage
sudo dmsetup table company_storage-shared_documents
```

`lvdisplay -m` prints a `Segments` block. For a 200 MiB volume with 4 MiB extents you expect one segment of type `linear` that covers logical extents 0 to 49 and names the physical volume and its physical extent range. `lvs -o +seg_pe_ranges` prints the same range in one line. `dmsetup table` is the kernel's own copy of the list: a line that starts `0 409600 linear`, then the major and minor number of the disk, then the offset. Here 409600 is the volume size in 512-byte sectors, which is 200 MiB. If `vdc` and `vdd` both hold extents of one volume, you see one line per segment.

`sudo dmsetup ls` lists every device-mapper device on the machine. Your volume appears as `company_storage-shared_documents`.

## Making the mount come back

A `mount` command is forgotten at reboot. A line in `/etc/fstab` makes the mount happen at every launch. For an LV the device name is stable, so you can use the mapper path. You can also use the filesystem UUID, which `blkid` prints.

Save this line at the end of `/etc/fstab`. Make a copy first, because a bad line can stop a boot:

```sh
sudo cp /etc/fstab /etc/fstab.bak
echo '/dev/mapper/company_storage-shared_documents /mnt/shared_documents ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab
```

The six fields are: device, mount point, filesystem type, options, dump flag (0, not used), and the fsck order (2 for non-root filesystems). `nofail` lets the boot go on if this volume is missing.

Apply it and test it without rebooting. Unmount first so that `mount -a` has real work to do:

```sh
sudo umount /mnt/shared_documents
sudo systemctl daemon-reload
sudo findmnt --verify
sudo mount -a
```

Then check it:

```sh
findmnt /mnt/shared_documents
```

`findmnt --verify` reads `/etc/fstab` and reports errors. `mount -a` mounts every fstab line that is not mounted. If the last command shows the mount point with source `/dev/mapper/company_storage-shared_documents` and type `ext4`, the line works. If it prints nothing, read the message from `mount -a` and fix the line before you reboot.

## Common pitfalls

> [!WARNING]
> - **Editing `/etc/fstab` and rebooting to test.** A typo can drop the machine into emergency mode. Run `sudo findmnt --verify` and `sudo mount -a` first.
> - **Forgetting that dashes are doubled in the mapper name.** `/dev/mapper/my-vg-my-lv` does not exist. The real name is `my--vg-my--lv`. Use `ls /dev/mapper` to read it, or use the `/dev/<vg>/<lv>` path.
> - **Using `/dev/vdc` style names for the filesystem in fstab.** Use the LV path or the UUID. The `vdX` letters can change between boots.
> - **Reading `dmsetup table` as a place to edit.** It is the kernel's view. Change volumes with the `lv*` commands so that the metadata and the kernel stay the same.
