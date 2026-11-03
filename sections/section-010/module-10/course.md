# Btrfs Basics

Astronaut, most holds on your ship use ext4 shelving, but some ships build their holds with Btrfs. A Btrfs hold can be split into several named shelves that share one pool of space, and it can take a photograph of a shelf in a moment. The exam can ask you to create, mount, resize and inspect one.

In this module you format a disk as Btrfs, cut a subvolume from it and mount that subvolume at its own hatch, so it returns at every launch. Then you take snapshots, grow and shrink the filesystem while it is mounted, and learn why `df` gives an unreliable answer on Btrfs.

## Learning objectives

After this module you can:

- Explain in plain words what copy-on-write means and why Btrfs does not need a separate `mkfs` step per shelf.
- Create a Btrfs filesystem with a label using `mkfs.btrfs -L`, mount it and read it with `btrfs filesystem show`, `btrfs filesystem df` and `btrfs filesystem usage`.
- Create and list subvolumes with `btrfs subvolume create` and `btrfs subvolume list`.
- Mount a subvolume instead of the whole filesystem with the `subvol=` option, and make that mount persistent in `/etc/fstab` by UUID.
- Take read-only and writable snapshots with `btrfs subvolume snapshot`, and delete a subvolume.
- Grow and shrink a mounted Btrfs filesystem with `btrfs filesystem resize`.
- Explain why `df` is not the right tool to check free space on Btrfs.

## Before you start

Every mission starts with a pre-flight check. Make sure you know the basics below, and know what waits for you in your training ship.

### What you should already know

- How to find a spare disk with `lsblk` and mount a filesystem on a mount point.
- The six fields of an `/etc/fstab` line, and why a device is named by `UUID=`.

### What is in your playground

Your playground is one training spaceship: an Ubuntu 24.04 virtual machine with passwordless `sudo`.

- Two spare disks, blank and unformatted: a 2 GB disk, reachable as `/dev/disk/by-id/virtio-s010m10-a`, and a 1 GB disk, reachable as `/dev/disk/by-id/virtio-s010m10-b`. They are usually `/dev/vdb` and `/dev/vdc`. Always confirm the names with `lsblk`.
- The Btrfs tools come from the package `btrfs-progs`. The playground installs it if it is missing. Check with `command -v mkfs.btrfs`.
- The original `/etc/fstab` is saved as `/etc/fstab.orig`, so you can roll back any change.

Start the playground and connect to it with `astrona ssh section-010-module-10-playground`. Run every command in the parts in that shell.

<!-- astrona:playground -->

## The parts of this module

1. [Creating Btrfs and Subvolumes](./course-01-creating-btrfs-and-subvolumes.md): copy-on-write in plain words, formatting, mounting, inspecting, subvolumes and a persistent subvolume mount.
2. [Snapshots and Resizing](./course-02-snapshots-and-resizing.md): read-only and writable snapshots, deleting subvolumes, growing and shrinking a mounted filesystem, and why `df` misleads.
3. [Wrap-Up: Mission Debrief](./course-03-wrap-up.md): what you learned, your mission, questions to check yourself, and cleanup.
