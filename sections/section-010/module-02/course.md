# Splitting the Hold: Partitioning Raw Storage

A new disk is an empty cargo hold: one long run of space, with no walls and no labels. Before you build shelves in it with a filesystem, you almost always split it into rooms first. Each room is a **partition**, and the deck plan that lists the rooms is the **partition table**.

Astronaut, in this module you learn the two kinds of deck plan, MBR and GPT, and why GPT is the one to choose. Then you draw rooms yourself with `fdisk` and `parted`, start them in the right place, and make the ship's core (the kernel) see the new plan.

## Learning objectives

After this module you can:

- Explain what a partition table is, and how MBR and GPT differ in the number of partitions, the largest disk they can use, and how many copies of the table they keep.
- Choose GPT over MBR for any modern disk, and say why.
- Create a GPT label and an aligned partition with `parted` in one go, and describe the same steps in an `fdisk` session.
- Explain write amplification, and why partitions start at sector 2048 to avoid it.
- Recognise the "kernel still uses the old table" message, explain what the `BLKRRPART` request does, and fix the problem with `partprobe`.

## Before you start

Every mission starts with a pre-flight check. Make sure you know the basics below, and know what waits for you in your training ship.

### What you should already know

- How to find a disk with `lsblk` and see what is on it with `blkid`.
- How to move around a Linux shell and run commands with `sudo`.

### What is in your playground

Your playground is one training spaceship: an Ubuntu 24.04 virtual machine with passwordless `sudo`.

- The system disk, `/dev/vda`, holds the operating system.
- One extra 12 GB disk has **no partition table** at all. It is usually `/dev/vdb`, and it is also reachable as `/dev/disk/by-id/virtio-s10m02-raw`. Always confirm the name with `lsblk`. The playground clears this disk's partition tables every time it starts.
- The partitioning tools are already installed: `fdisk`, `parted`, `sfdisk`, `partprobe`, `lsblk`, `blkid` and `wipefs`.

Start the playground and connect to it with `astrona ssh section-010-module-02-playground`. Run every command in the parts in that shell.

<!-- astrona:playground -->

## The parts of this module

Read the parts in this order. The mission comes right after the part it tests.

1. [Partition Tables: MBR vs GPT](./course-01-partition-tables-mbr-vs-gpt.md): what each kind of deck plan stores on the disk, and why GPT keeps two checked copies.
2. [Write an Aligned GPT Partition](./course-02-write-an-aligned-gpt-partition.md): write a table with `fdisk` and `parted`, and why the first partition starts at sector 2048. Ends with your mission.
3. [When the Kernel Keeps the Old Table](./course-03-when-the-kernel-keeps-the-old-table.md): why the kernel's copy of the table can lag behind the disk, and how `partprobe` fixes it.
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md): what you learned, your mission, questions to check yourself, and cleanup.
