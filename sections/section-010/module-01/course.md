# The Lifecycle of Local Storage

When you plug a USB stick into a laptop, a file manager window usually pops open a few seconds later. On a Linux server, nothing happens. A new disk is an empty cargo hold: the ship's core (the kernel) can see the space, but there are no shelves, no labels and no hatch to reach it through.

Astronaut, in this module you turn that empty hold into a place where you can store files. You find the raw disk, build the shelves on it with a filesystem, and dock it to the ship's one corridor of directories. Then you learn what to do when a hold refuses to undock because crew members are still inside it, and how to find cargo hidden on shelves you cannot see.

## Learning objectives

After this module you can:

- Tell a raw, unformatted disk apart from a formatted one with `lsblk` and `blkid`.
- Create an ext4 filesystem on a raw disk with `mkfs.ext4`, and explain why a filesystem can run out of room for new files while it still has free space (its inode budget is fixed when you format it).
- Explain what `mount` changes in the kernel's table of active mounts, and why mounting and unmounting take the same short time for any size of disk.
- Mount a filesystem on a directory and confirm the result with `df -h`.
- Explain why the kernel refuses to unmount a filesystem that is in use, using the count of references it keeps.
- Find which process holds a mount open, and which kind of hold it has (an open file, its working directory, its program file or a memory-mapped file), with `lsof` and `fuser -mv`.
- Stop a blocking process safely: send `SIGTERM` first, and `SIGKILL` only if that fails.
- Find space used by hidden dot-directories with `ls -la` and `du -sh`.

## Before you start

Every mission starts with a pre-flight check. Make sure you know the basics below, and know what waits for you in your training ship.

### What you should already know

- How to move around a Linux shell: `cd`, `ls`, `sudo`, and reading command output.
- You do not need any earlier storage experience.

### What is in your playground

Your playground is one training spaceship: an Ubuntu 24.04 virtual machine with passwordless `sudo`.

- The system disk, `/dev/vda`, holds the operating system and is mounted at `/`.
- One extra 2 GB disk is attached raw and unformatted. It is usually `/dev/vdb`, and it is also reachable as `/dev/disk/by-id/virtio-s10m01-raw`. Always confirm the name with `lsblk`. The playground wipes this disk back to raw every time it starts.
- Every tool in this module is already installed: `lsblk`, `blkid`, `mkfs.ext4`, `mount`, `df`, `lsof` and `fuser`.

Start the playground and connect to it with `astrona ssh section-010-module-01-playground`. Run every command in the parts in that shell.

<!-- astrona:playground -->

## The parts of this module

1. [Discovery, Formatting and Mounting](./course-01-discovery-formatting-mounting.md): find the raw disk, put an ext4 filesystem on it, and mount it.
2. [Diagnosing a Stuck Disk](./course-02-diagnosing-a-stuck-disk.md): find the process that keeps a mount busy, stop it safely, and unmount.
3. [Finding Hidden Space](./course-03-finding-hidden-space.md): find disk space used by hidden dot-directories.
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md): what you learned, your missions, questions to check yourself, and cleanup.
