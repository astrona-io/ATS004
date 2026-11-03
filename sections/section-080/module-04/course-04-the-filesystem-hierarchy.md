# The Filesystem Hierarchy

Every Linux ship follows the same deck plan, called the Filesystem Hierarchy Standard (FHS). It says which directory holds what. When you know the plan, you know where to look for configuration, where logs grow, and which directories can fill a disk.

## The main directories

Think of the root `/` as the main corridor of the ship, with a standard set of doors off it. These are the ones the exam expects you to know:

| Directory | What belongs there |
| --- | --- |
| `/etc` | Configuration files for the system and its services |
| `/var` | Data that changes while the system runs: logs, caches, queues, databases |
| `/usr` | Programs, libraries and shared files that come with the system |
| `/opt` | Add-on software packaged as one directory each |
| `/srv` | Data that the machine serves, such as web pages or file shares |
| `/home` | The home directory of each user |
| `/tmp` | Temporary files that any user may write |
| `/run` | Runtime data since the last boot, held in memory |
| `/boot` | The kernel and the files used at startup |

The directories that grow are `/var` (logs and caches), `/home` and `/srv`. Fixed files sit in `/usr` and `/etc`. This is why a capacity audit often starts with `du -hx -d 1 /var`.

## The usrmerge on Ubuntu 24.04

On Ubuntu 24.04, `/bin`, `/sbin` and `/lib` are symlinks to `/usr/bin`, `/usr/sbin` and `/usr/lib`. So all programs really live under `/usr`. The old paths still work because the kernel swaps them in while resolving a path.

<!-- astrona:playground:renew -->

### See it in your playground

Look at the top level and at which directories are separate mounts:

```sh
ls -l /
findmnt -no TARGET,FSTYPE /run /tmp /boot
```

The first command shows `bin`, `sbin` and `lib` as links. The second prints the mount point and filesystem type for each of those directories that is a separate mount. The directories that are not separate mounts are not listed. `/run` is held in memory, so its type is `tmpfs`.

Ask where a program really lives:

```sh
command -v ls
realpath "$(command -v ls)"
```

The first command prints the path you would run. The second prints the real file under `/usr`.

## Why it matters for storage work

Separate disks are often mounted on `/var`, `/home`, `/srv` or `/opt`, so one directory can fill without touching the rest. When you audit one disk, stay on it with `-x`. When you search for files on the root disk only, `find` has the same switch, `-xdev`:

```sh
sudo find / -xdev -type f -size +100M 2>/dev/null
```

This lists files over 100 MiB on the root filesystem and skips other mounts. If it prints nothing, no file that large exists on the root filesystem.

## Common pitfalls

> [!WARNING]
> - **Putting data in the wrong place.** Logs belong in `/var/log` and configuration in `/etc`. Tools and backups look in the standard places.
> - **Storing anything you need in `/tmp` or `/run`.** `/run` is memory and is empty after a reboot. `/tmp` may be cleaned at boot.
> - **Searching all of `/` with `find` without `-xdev`.** It crosses into `/proc`, `/sys` and network mounts.
> - **Assuming `/bin` is a directory.** On this system it is a link. Scripts that test with `-d` on the path see a directory only because the link is followed.

## Your mission: Place Files by FHS and Link Them Lab

You can now tell where each kind of file belongs in the standard deck plan, and link files. The mission asks you to move four files to their proper places, then make one hard link and two symbolic links with `ln`.

The mission runs on its own training ship. A playground cannot be paused, so remove it first to free memory. It always starts clean again:

```sh
astrona destroy section-080-module-04-playground
```

Then start the mission and connect to it:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-080/module-04/labs/lab-02
astrona ssh ats-004-lab-080-04-02
```

Read the task in [`question.md`](./labs/lab-02/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-080/module-04/labs/lab-02
```

When the mission is done, remove it and start a fresh playground:

```sh
astrona destroy ats-004-lab-080-04-02
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-080/module-04/playground
```
