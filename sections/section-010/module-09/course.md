# XFS: Creating, Growing and Repairing

Astronaut, ext4 is not the only shelving system a ship can build inside a cargo hold. **XFS** is another one, and it is the default on several large server distributions. It is built for big holds and many crew members writing at once. The exam expects you to create it, grow it, check it and repair it by hand.

XFS has its own tools, and they do not work like the ext4 tools. It can grow while the ship flies, but it can never shrink. Its repair crew only works on a hold that is undocked. In this module you build an XFS filesystem, make it dock at every launch, grow it, and run a safe repair check.

## Learning objectives

After this module you can:

- Create an XFS filesystem with `mkfs.xfs`, give it a label, and read its layout with `xfs_info`.
- Explain what the log and the allocation groups are, and say why XFS can grow but never shrink.
- Mount an XFS filesystem with options such as `noatime`, and make the mount survive a reboot with a `UUID=` line in `/etc/fstab`.
- Grow a mounted XFS filesystem with `xfs_growfs` after its device has become larger.
- Check an XFS filesystem with `xfs_repair -n`, and repair it with `xfs_repair` only while it is not mounted.
- Explain why `fsck.xfs` does nothing, and why `xfs_repair -L` is a last resort.
- Change a label or a UUID with `xfs_admin`.

## Before you start

Every mission starts with a pre-flight check. Make sure you know the basics below, and know what waits for you in your training ship.

### What you should already know

- How to find a disk with `lsblk`, and how to mount and unmount a filesystem.
- The six fields of an `/etc/fstab` line, and why a device is named by `UUID=`.

### What is in your playground

Your playground is one training spaceship: an Ubuntu 24.04 virtual machine with passwordless `sudo`.

- Two blank spare disks: a 1 GB disk (serial `s010m09-a`) and a 2 GB disk (serial `s010m09-b`). They are usually `/dev/vdb` and `/dev/vdc`, and they are also reachable as `/dev/disk/by-id/virtio-s010m09-a` and `/dev/disk/by-id/virtio-s010m09-b`. Always confirm the names with `lsblk`.
- The original `/etc/fstab` is saved as `/etc/fstab.orig`, so you can roll back any change.
- `xfsprogs` (the XFS tools), `blkid`, `findmnt` and `lsblk` are installed.

Start the playground and connect to it with `astrona ssh section-010-module-09-playground`. Run every command in the parts in that shell.

<!-- astrona:playground -->

## The parts of this module

1. [Creating and Inspecting XFS](./course-01-creating-and-inspecting-xfs.md): build an XFS filesystem, read its layout, mount it with options, and make the mount persistent.
2. [Growing and Repairing XFS](./course-02-growing-and-repairing-xfs.md): grow a docked filesystem, run a safe repair check, and know when the repair crew is allowed to work.
3. [Wrap-Up: Mission Debrief](./course-03-wrap-up.md): what you learned, your mission, questions to check yourself, and cleanup.

<!-- curriculum-practice -->
## Practice and assessment

- [XFS Create, Mount and Check Lab](labs/lab-01/question.md): Format a blank disk as XFS with the label NEWCARGO; Mount it at /srv/newcargo by UUID through /etc/fstab with the options defaults,noatime; Dry-run xfs_repair -n on an unmounted XFS disk and save the output without changing the disk.
- [Local Storage Integration Capstone Lab](../capstone/labs/lab-01/question.md): Find the unused disk, format it with ext4, mount it at /mnt/backup-black and add an empty completed file; Compare usage of the two mounted disks with df and empty the hidden .trash folder on the fuller one; Find the process using more memory and unmount the disk that holds its executable.
