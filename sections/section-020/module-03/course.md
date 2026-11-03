# Network Block Devices: NBD and iSCSI

<!-- astrona:playground -->
> [!NOTE]
> Hands-on playground for this module: a clean, throwaway pair of machines to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-020/module-03/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-020/module-03/playground
> astrona destroy section-020-module-03-playground
> ```

Astronaut, a shared file server hands you a finished shelf of files. A network block device hands you something else: a bare, empty cargo hold from another ship. Your ship builds its own shelves inside it, docks it, and treats it like a local disk, even though the hold sits far away on the communications array.

In this module you work as the client. You attach a disk over the network in two ways: with NBD, a very simple protocol, and with iSCSI, the one used in real data centres. You then format the disk, mount it, and make it come back after a restart.

## Learning objectives

After this module you can:

- Explain the difference between a remote filesystem (NFS) and a network block device, and say which machine owns the filesystem in each case.
- List the exports of an NBD server, connect one to `/dev/nbd0`, use it, and disconnect it with `nbd-client`.
- Discover iSCSI targets with `iscsiadm`, log in and log out, and read a target name (an IQN).
- Find the new disk with `lsblk` and `/dev/disk/by-path/`, then create a filesystem on it and mount it.
- Write a persistent `/etc/fstab` line for a network disk with `UUID=` and `_netdev`, and explain why `_netdev` is needed.
- Make an iSCSI login automatic with `node.startup`, and check that the `iscsid` service is running.

## Before you start

### What you should already know

- How to format a whole disk with `mkfs.ext4` and mount it with `mount`.
- The six fields of an `/etc/fstab` line.

### What is in your playground

Your playground is two training spaceships on the private network `10.10.60.0/24`. Both are Ubuntu 24.04 virtual machines with passwordless `sudo`.

- `client` (10.10.60.5) is where you work. `nbd-client` and `open-iscsi` are installed, and the empty folder `/mnt/cargo` exists.
- `server` (10.10.60.10) was prepared for you. It offers a 1 GB disk over iSCSI under the target name `iqn.2026-01.io.astrona:storage.cargo`, and a 512 MB disk over NBD under the export name `cargo`.
- The tools are installed with `apt` when the machines start, so the machines need a working network at start-up.

Connect with `astrona ssh section-020-module-03-playground` and choose `client`. Run every command in the parts on `client`.

## The parts of this module

1. [Block Devices Versus Shared Files, and NBD](./course-01-block-versus-file-sharing-and-nbd.md): what a network block device is, and how to attach, use and detach an NBD export.
2. [The iSCSI Initiator: Discover, Log In and Mount](./course-02-iscsi-initiator-login-and-mount.md): find a target, log in, locate the new disk, format and mount it.
3. [Making the Disk Come Back After a Restart](./course-03-persistence-and-pitfalls.md): the `_netdev` fstab line, automatic login, and the mission.
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md): what you learned, your mission, questions to check yourself, and cleanup.
