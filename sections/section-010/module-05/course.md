# /etc/fstab in Depth

Astronaut, a `mount` command docks a cargo hold to your ship only until the next landing. When the ship launches again, only what is written in its logbook comes back. That logbook is `/etc/fstab`, the filesystem table, and systemd (the ship's duty officer) reads it at every launch to dock each hold it lists.

The logbook is also where one small mistake can stop a ship from booting normally. In this module you learn the six fields of an entry, which identifier to use for the disk, the options that matter, and how to check an entry is safe *before* you rely on it at boot.

## Learning objectives

After this module you can:

- Name the six fields of an `/etc/fstab` line and say what each one controls.
- Choose `UUID=`, `LABEL=` or `PARTUUID=` instead of a `/dev/sdX` path, and say why.
- Pick sensible mount options, including when to add `nofail` and `_netdev`, and explain what each one changes at boot.
- Set the `dump` and `pass` fields correctly for a data filesystem, the root filesystem and swap.
- Test an entry with `sudo mount -a` and `findmnt --verify` before you trust it at boot.

## Before you start

Every mission starts with a pre-flight check. Make sure you know the basics below, and know what waits for you in your training ship.

### What you should already know

- How to mount and unmount a filesystem by hand with `mount` and `umount`.
- How to read the output of `blkid` and `lsblk`.

### What is in your playground

Your playground is one training spaceship: an Ubuntu 24.04 virtual machine with passwordless `sudo`.

- Two spare 1 GB disks, each with an ext4 filesystem already on it, labelled `DATA1` and `DATA2`. They are usually `/dev/vdb` and `/dev/vdc`, and they are also reachable as `/dev/disk/by-id/virtio-s015m01-a` and `/dev/disk/by-id/virtio-s015m01-b`. Run `sudo blkid` to see which is which.
- A backup of the original logbook at `/etc/fstab.orig`. Editing `/etc/fstab` here is safe: `sudo cp /etc/fstab.orig /etc/fstab` puts it back.
- Every tool in this module is already installed: `findmnt`, `blkid`, `lsblk` and `mount`.

Start the playground and connect to it with `astrona ssh section-010-module-05-playground`. Run every command in the parts in that shell.

<!-- astrona:playground -->

## The parts of this module

1. [fstab Fields and Stable Identifiers](./course-01-fields-and-stable-identifiers.md): the six fields of an entry, and why `UUID=` beats a `/dev/` path.
2. [Options and Verifying Before You Trust It](./course-02-options-and-verifying.md): `nofail`, `_netdev` and `noatime`, and the safe check with `findmnt --verify` and `mount -a` before a reboot.
3. [Wrap-Up: Mission Debrief](./course-03-wrap-up.md): what you learned, your mission, questions to check yourself, and cleanup.
