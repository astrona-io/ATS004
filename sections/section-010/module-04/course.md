# The Digital Auditor: Filesystem Maintenance, Labeling, and Tuning

A filesystem is the shelving and labelling system inside a cargo hold, and it keeps careful lists of every item on its shelves. A clean landing leaves those lists in order. A power cut or a failing disk in the middle of a write can leave them disagreeing, and then the hold may refuse to dock.

Astronaut, in this module you become the hold's auditor. You call in the repair crew (`fsck`) safely, give the hold a painted name and read its serial number, and write it into the ship's logbook so it docks at the right hatch after every launch. You also decide how often the repair crew should inspect the hold on its own.

## Learning objectives

After this module you can:

- Explain what the superblock and the journal store, and why the journal makes most crashes quick to recover from.
- State the rule never to run `fsck` on a mounted filesystem, and explain why breaking it really damages data.
- Run `fsck` in read-only mode (`-n`) and automatic-repair mode (`-y`), and read the passes it reports.
- Set a filesystem label with `tune2fs -L`, and read a filesystem's UUID with `blkid`.
- Mount a filesystem by `LABEL=` or `UUID=` instead of by a device name such as `/dev/vdb`, and explain why that is safer in `/etc/fstab`.
- Plan, and turn off, a regular full check with `tune2fs -c` and `-i`, separate from the journal replay.

## Before you start

Every mission starts with a pre-flight check. Make sure you know the basics below, and know what waits for you in your training ship.

### What you should already know

- How to create an ext4 filesystem with `mkfs.ext4` and mount it on a directory with `mount`.
- How to run commands with `sudo` and read their output.

### What is in your playground

Your playground is one training spaceship: an Ubuntu 24.04 virtual machine with passwordless `sudo`.

- The system disk, `/dev/vda`, holds the operating system.
- One extra 2 GB disk holds an **unmounted** ext4 filesystem labelled `OLD_LABEL`, with a few sample files (`report.txt` and `archive/notes.txt`). It is usually `/dev/vdb`, and it is also reachable as `/dev/disk/by-id/virtio-s10m04-fs`. Always confirm the name with `lsblk -f`. Because it is unmounted, it is safe to run `fsck` on it. The playground builds this filesystem again every time it starts.
- Every tool in this module is already installed: `fsck`, `e2fsck`, `tune2fs`, `dumpe2fs`, `blkid` and `lsblk`.

Start the playground and connect to it with `astrona ssh section-010-module-04-playground`. Run every command in the parts in that shell.

<!-- astrona:playground -->

## The parts of this module

1. [Filesystem Corruption and the fsck Repair Model](./course-01-fsck-repair-model.md): how a crash leaves a filesystem's lists disagreeing, what the superblock and the journal store, and how to run `fsck` safely.
2. [Labels, UUIDs and Tuning Check Intervals](./course-02-labels-uuids-and-tuning.md): give a filesystem a stable label, mount it by UUID, and plan regular checks with `tune2fs`.
3. [Wrap-Up: Mission Debrief](./course-03-wrap-up.md): what you learned, your mission, questions to check yourself, and cleanup.
