# The Hardware Tree & Runtime Tuning: /sys & sysctl

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-060/module-02/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-060/module-02/playground
> astrona destroy section-060-module-02-playground
> ```

Astronaut, the ship's core has a control panel. `/sys` is the part of it that shows every device on board, one small file for each fact. Next to it, the files under `/proc/sys/` are dials: you write a value and the core changes how it works, at once, with no restart.

In this module you read device facts, learn why some files are readouts and others are dials, change a dial with `sysctl`, and then write the change into the logbook so it comes back at every launch.

## Learning objectives

After this module you can:

- Read a device attribute (such as a disk's sector size) from `/sys/class/...`, and explain the `show`/`store` mechanism that makes some `/sys` files read-only and others controls.
- Explain why `/proc/mounts` is the authoritative list of mounted filesystems, and what `/etc/mtab` actually is today.
- Read a disk's I/O scheduler, rotational flag and queue size from `/sys/block/<dev>/queue/`, and change one for the running ship.
- Make a `/sys` change survive a reboot with a udev rule.
- View a kernel parameter with `sysctl <name>` and map the dot-name to its `/proc/sys/` path.
- Change a parameter at runtime with `sysctl -w` (and know why `sudo echo 1 > ...` fails).
- Make a parameter change persist across reboots with a file in `/etc/sysctl.d/`.
- State how the files in the `sysctl.d` directories and `/etc/sysctl.conf` are ordered when more than one sets the same key.

## Before you start

Every mission starts with a pre-flight check. Make sure you know the basics below, and know what waits for you in your training ship.

### What you should already know

- That `/proc` holds files the kernel generates on demand, so reading one runs a kernel function.
- How to use `cat`, `grep` and `sudo`.

### What is in your playground

Your playground is one training spaceship: an Ubuntu 24.04 virtual machine with passwordless `sudo`.

- A 1 GB spare disk, usually `/dev/vdb`, so your `/sys` reads target a disk that is not the root disk. Always confirm the name with `lsblk`.
- `bootstrap/prepare.sh` prints the root filesystem type and the starting `ip_forward` value when the ship starts.
- `sudo` is needed only for writes to `/proc/sys` and `/sys` and for files under `/etc`.

Start the playground and connect to it with `astrona ssh section-060-module-02-playground`. Run every command in the parts in that shell.

## The parts of this module

1. [The Hardware Tree & the Mount List](./course-01-hardware-tree-and-mount-list.md): the `show` and `store` mechanism behind `/sys`, reading device attributes, and why `/proc/mounts` is the mount list to trust.
2. [Block Queue Attributes & udev Rules](./course-02-block-queue-attributes-and-udev.md): the disk dials under `/sys/block/<dev>/queue/`, and how a udev rule makes a change survive a reboot.
3. [sysctl: Viewing and Changing Parameters](./course-03-sysctl-viewing-and-changing.md): `sysctl` as a name map onto `/proc/sys/`, and why `sudo echo >` fails.
4. [sysctl: Persisting and Precedence](./course-04-sysctl-persisting-and-precedence.md): drop-in files, `sysctl --system` and the ordering rule that decides which file wins.
5. [Wrap-Up: Mission Debrief](./course-05-wrap-up.md): what you learned, your mission, questions to check yourself, and cleanup.
