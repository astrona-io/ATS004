# Under Lock and Key: Securing Data-at-Rest with LUKS

File permissions only guard your cargo while your own ship is flying. If someone pulls the disk out and reads it on another machine, nobody checks the permissions. The bytes are simply there to read. To protect data "at rest", that is, sitting on a disk that someone else holds, the disk itself must be encrypted.

Astronaut, in this module you fit a vault door on a cargo hold. On Linux that vault door is LUKS (Linux Unified Key Setup): without the passphrase, nobody gets to the cargo. You learn what LUKS guards against, how its keys work, and the `cryptsetup` commands to lock, open, use and close an encrypted disk.

## Learning objectives

After this module you can:

- Describe the threat LUKS protects against (someone holds your disk, but not your running system), and what it does not protect against.
- Explain the two states of a LUKS disk, locked and mapped, and why disk encryption uses the AES-XTS cipher mode.
- Create a LUKS container on a disk with `cryptsetup luksFormat`.
- Explain what the master key and the keyslots do, and add a second passphrase with `luksAddKey` without touching the stored data.
- Open a LUKS disk to a `/dev/mapper/` name, put a filesystem on the mapped device, mount it, and then unmount and `close` it.
- Predict what the raw disk shows to someone without the passphrase, and explain why.

## Before you start

Every mission starts with a pre-flight check. Make sure you know the basics below, and know what waits for you in your training ship.

### What you should already know

- How to format a disk with `mkfs.ext4`, and how to mount and unmount it with `mount` and `umount`.
- How to run commands as the captain with `sudo`, and how to read command output.

### What is in your playground

Your playground is one training spaceship: an Ubuntu 24.04 virtual machine with passwordless `sudo`.

- The system disk, `/dev/vda`, holds the operating system.
- One extra 2 GB disk is attached raw, with nothing on it. It is usually `/dev/vdb`, and it is also reachable as `/dev/disk/by-id/virtio-s10m03-raw`. Always confirm the name with `lsblk`. The playground wipes this disk back to raw every time it starts.
- The tools are already installed: `cryptsetup`, the `dm_crypt` kernel module, `mkfs.ext4`, `lsblk`, `blkid` and `xxd`.

Start the playground and connect to it with `astrona ssh section-010-module-03-playground`. Run every command in the parts in that shell.

<!-- astrona:playground -->

## The parts of this module

1. [The LUKS Model: Locking a Disk](./course-01-the-luks-model.md): what LUKS protects against, and how a locked disk turns into a usable one.
2. [Creating a Container and Its Keyslots](./course-02-creating-a-container-and-keyslots.md): lock a disk with `luksFormat`, and give it a second passphrase.
3. [Opening, Using and Closing the Vault](./course-03-opening-using-closing.md): open the disk, put a filesystem on it, close it again, and look at the raw bytes.
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md): what you learned, your mission, questions to check yourself, and cleanup.
