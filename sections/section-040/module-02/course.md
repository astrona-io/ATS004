# Permanent Swap Partitions and Priority Scheduling

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-040/module-02/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-040/module-02/playground
> astrona destroy section-040-module-02-playground
> ```

A swap file is convenient, but every page it handles passes through the filesystem driver on its way to disk. A dedicated swap partition skips that layer: the kernel writes memory pages straight onto the partition's raw blocks. Astronaut, think of it as a hold built only for overflow, with no shelves to walk through.

In this module you build a swap partition, make swap come back after a reboot through `/etc/fstab`, and set priorities so the kernel fills the fast hold first. You also learn to read the swap table and fix a swap area that will not start.

## Learning objectives

After this module you can:

- Explain why a swap partition avoids the filesystem-driver cost a swap file has.
- Create a swap partition with `parted`, format it with `mkswap` and activate it with `swapon`.
- Set swap priorities with `pri=` (on the command line and in `/etc/fstab`) and predict the fill order from the kernel's priority-bucket mechanism.
- Write `/etc/fstab` swap lines keyed by `UUID=` and apply them with `swapoff -a` and `swapon -a`.
- Label a swap area, read `/proc/swaps`, and diagnose a swap area that will not start.

## Before you start

Every mission starts with a pre-flight check. Know the basics below, and know what waits for you in your training ship.

### What you should already know

- What swap is, and the commands `mkswap`, `swapon`, `swapoff` and `swapon --show`. A swap file is made with `fallocate`, locked with `chmod 600` and formatted with `mkswap`.
- How to partition a disk with `parted`.

### What is in your playground

Your playground is one training spaceship: an Ubuntu 24.04 virtual machine with 2 GB of memory and passwordless `sudo`.

- One spare 1 GB disk, usually `/dev/vdb`, and also reachable as `/dev/disk/by-id/virtio-s40m02-swap`. It starts raw (wiped), and you must confirm its name with `lsblk`.
- The original `/etc/fstab` is saved as `/etc/fstab.orig`, so you can roll back any edit with one command.
- No swap is active at the start.

Start the playground and connect to it with `astrona ssh section-040-module-02-playground`. Run every command in the parts in that shell.

## The parts of this module

1. [Partition Versus File, and Creating the Partition](./course-01-partition-vs-file-and-creating-it.md): why a partition skips a layer, and how to carve one.
2. [Formatting, Activating and Priorities](./course-02-formatting-activating-and-priorities.md): `mkswap`, `swapon`, and the priority buckets behind `pri=`.
3. [Making Swap Persistent in /etc/fstab](./course-03-persistence-in-fstab.md): the fstab lines, the safe check, and your graded mission.
4. [Labels, the Swap Table and Fixing a Swap That Will Not Start](./course-04-labels-swap-table-and-troubleshooting.md): reading `/proc/swaps` and diagnosing a failed `swapon`.
5. [Wrap-Up: Mission Debrief](./course-05-wrap-up.md): what you learned, your mission, questions to check yourself, and cleanup.

<!-- curriculum-practice -->
## Practice and assessment

- [Swap Partition Formatting & Priorities Lab](labs/lab-01/question.md): Format the dedicated disk as swap and activate it; Give the disk swap priority 10 and the existing /swapfile priority 5; Persist both swap areas with their priorities in /etc/fstab.
- [Swap Space Management Capstone Lab](../capstone/labs/lab-01/question.md): Create, secure and activate a 2G swap file and persist it in /etc/fstab; Find the unformatted partition with lsblk and activate it as swap; Prefer the partition by giving it priority 10 and the swap file priority 5.
