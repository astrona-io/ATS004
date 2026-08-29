# The Lifecycle of Local Storage

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-010/module-01/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-010/module-01/playground
> astrona destroy section-010-module-01-playground
> ```

When you plug a USB stick into a laptop, a file manager window usually pops open a few seconds later. On a Linux server, nothing happens. A newly attached disk is just a block of raw sectors that the kernel can see but has not been told what to do with. Turning that raw hardware into a directory you can write files to is a deliberate, several-step process, and doing it is a core part of a system administrator's job.

This chapter walks through that process end to end: how Linux presents a disk before it is usable, how you put a filesystem on it, how you attach that filesystem to the directory tree, and how you deal with the common problem of a disk that refuses to detach because something is still using it.

## Learning objectives

After this module you can:

- Tell a raw, unformatted block device apart from a formatted one using `lsblk` and `blkid`.
- Create an ext4 filesystem on a raw disk with `mkfs.ext4`.
- Mount a filesystem onto a directory and confirm the result with `df -h`.
- Explain why the kernel refuses to unmount a filesystem that is in use.
- Identify which process is holding a mount open using `lsof` and `fuser`.
- Stop a blocking process safely by sending `SIGTERM` before escalating to `SIGKILL`.

## Before you start

You should be comfortable moving around a Linux shell: `cd`, `ls`, `sudo`, and reading command output. You do not need any prior storage experience.

The linked playground gives you an Ubuntu server VM with passwordless `sudo` and one spare 2 GB disk attached raw and unformatted (commonly `/dev/vdb`). Every command block below is meant to be run in that VM's shell after you have connected with `astrona ssh astro-section-010-module-01-playground`. All the tools used here — `lsblk`, `blkid`, `mkfs.ext4`, `mount`, `df`, `lsof`, `fuser` — are already installed.

## The unified file tree

On Windows, each disk gets its own letter: `C:`, `D:`, `E:`. The drives sit side by side, and you pick one by its letter.

Linux does not work that way. There is exactly one directory tree, and it starts at the root directory, written `/`. Every disk, whether it is an internal SSD, a USB drive, or a network share on another continent, has to be attached to *some directory inside that one tree* before you can use it. Attaching a disk to a directory is called **mounting**, and the directory it gets attached to is the disk's **mount point**. Once a disk is mounted at, say, `/mnt/backup`, writing a file to `/mnt/backup/report.txt` sends that data to the mounted disk; the kernel handles the redirection invisibly.

The layer that makes every kind of storage behave the same way to your programs is the kernel's **Virtual Filesystem (VFS)**. Because of VFS, an application writing a file does not need to know or care whether the target directory is on a local disk, a USB stick, or a remote server.

> As an analogy: mounting is like connecting a new wing to an existing building rather than parking a separate trailer outside. Visitors walk through the same front door and down the same hallways to reach the new rooms. The analogy breaks down in that a mounted disk can be detached cleanly at any time, which is not true of a building wing.

## Discovering an unformatted disk

A brand-new disk shows up to the kernel as a **raw block device**: the kernel knows its size and can read and write its sectors, but there is no filesystem on it, so it has no UUID, no label, and cannot be mounted yet.

The command to list what block devices the kernel currently sees is `lsblk` ("list block devices"). It prints a tree: whole disks (named `sda`, `sdb`, … on physical hardware, or `vda`, `vdb`, … on virtual machines) with any partitions carved out of them shown as indented children (`vda1`, `vda2`, …).

A disk that has a filesystem also has a 128-bit **UUID** (universally unique identifier) written into its header. The `blkid` ("block ID") command reads those headers and reports the UUID and filesystem type of every formatted device. A raw disk has no header for `blkid` to read, so it simply does not appear in the output. That absence is how you confirm a disk is safe to format: if `blkid` does not mention it, there is no filesystem there to destroy.

> [!TIP]
> **Try it — spot the raw disk**
>
> ```sh
> lsblk
> sudo blkid
> ```
>
> Expect something like:
>
> ```text
> NAME    MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS
> vda     254:0    0  15G  0 disk
> └─vda1  254:1    0  15G  0 part /
> vdb     254:16   0   2G  0 disk
>
> /dev/vda1: UUID="a1b2c3d4-..." TYPE="ext4" PARTUUID="..."
> ```
>
> `vda1` is mounted at `/` and shows up in `blkid` with a UUID and `TYPE`. `vdb` has no mount point, no children, and no line in `blkid` at all — that is the raw 2 GB disk, unformatted and safe to work on. Device names vary; confirm which one is the spare by its 2 GB size and empty mount point.

## Formatting: putting a filesystem on the disk

**Formatting** a disk means writing a **filesystem** onto it: an on-disk data structure that tracks file names, where each file's data blocks live, and metadata like permissions and timestamps. Without a filesystem, the disk is just an undifferentiated array of sectors.

This module uses **ext4** (the "fourth extended filesystem"), the long-standing default on many Linux distributions. It is a **journaling** filesystem, which matters for reliability: before changing its on-disk tables, ext4 writes a short description of the intended change to a reserved area called the journal. If power is lost mid-write, the kernel replays the journal on the next boot and the filesystem stays consistent instead of corrupting.

The tool that creates a filesystem is `mkfs` ("make filesystem"). You call the ext4-specific version directly:

```sh
sudo mkfs.ext4 /dev/vdb
```

This command overwrites the target. Running it on the wrong device destroys that device's data, so always confirm the device name with `lsblk` first. During the run, `mkfs.ext4` calculates the block count, reserves space for **inodes** (the per-file metadata records), and initializes the journal.

> [!TIP]
> **Try it — before and after formatting**
>
> ```sh
> sudo blkid /dev/vdb
> sudo mkfs.ext4 /dev/vdb
> sudo blkid /dev/vdb
> ```
>
> Expect something like:
>
> ```text
> (first blkid prints nothing and exits non-zero — no filesystem yet)
>
> mke2fs 1.47.0 (5-Feb-2023)
> Creating filesystem with 524288 4k blocks and 131072 inodes
> ...
> Writing superblocks and filesystem accounting information: done
>
> /dev/vdb: UUID="9f8e7d6c-5b4a-3210-fedc-ba9876543210" TYPE="ext4"
> ```
>
> The first `blkid` says nothing because there is no filesystem to identify. After `mkfs.ext4`, the same command reports a fresh UUID and `TYPE="ext4"` — the disk now carries a filesystem.

## Mounting: attaching the disk to the tree

A formatted disk still is not usable until it is mounted. Trying to `cd /dev/vdb` fails, because `/dev/vdb` is a device file, not a directory.

Mounting needs two things: an existing empty directory to serve as the mount point, and the `mount` command to connect the disk to it. Secondary disks are conventionally mounted under `/mnt`.

```sh
sudo mkdir -p /mnt/backup-black
sudo mount /dev/vdb /mnt/backup-black
```

After the `mount` call, any read or write under `/mnt/backup-black` goes to `/dev/vdb` instead of to the root disk. If the mount-point directory already contained files, those files are not deleted — they are hidden underneath the mount until you unmount, at which point they reappear.

The `df` ("disk free") command lists mounted filesystems with their capacity and usage; the `-h` flag makes the sizes human-readable.

> [!TIP]
> **Try it — confirm the mount**
>
> ```sh
> sudo mkdir -p /mnt/backup-black
> sudo mount /dev/vdb /mnt/backup-black
> df -h /mnt/backup-black
> sudo touch /mnt/backup-black/completed
> ls -l /mnt/backup-black
> ```
>
> Expect something like:
>
> ```text
> Filesystem      Size  Used Avail Use% Mounted on
> /dev/vdb        2.0G   24K  1.9G   1% /mnt/backup-black
> ...
> -rw-r--r-- 1 root root 0 Aug 29 12:00 /mnt/backup-black/completed
> ```
>
> `df` now lists `/dev/vdb` against the mount point `/mnt/backup-black`, and the `completed` file you created lives on the new disk's sectors, not on the root disk.

## When a disk will not unmount

Detaching a filesystem is done with `umount` (note the spelling — one `n`), taking either the device or the mount point:

```sh
sudo umount /mnt/backup-black
```

Often this just works. But if any process has a file open under the mount, or has its working directory inside it, the kernel refuses:

```text
umount: /mnt/backup-black: target is busy.
```

This is a safety feature. Unmounting a filesystem out from under a running program would drop its unwritten data and likely crash it, so the kernel blocks the unmount until nothing is using the filesystem any more. The most common culprit is your own shell sitting inside the directory — a shell's working directory counts as "in use".

Two tools identify what is holding a mount:

- `lsof` ("list open files") lists every open file on the system; `lsof +D <dir>` narrows that to files open under a directory tree. Its output includes the command name, the process ID (PID), the user, and the exact path.
- `fuser` ("file user") reports the PIDs using a path. With `-m` it treats the argument as a whole mounted filesystem, and with `-v` it prints a readable table including an `ACCESS` column (`c` = the process's current directory is here, `e` = its running executable is here, `f` = it has a file open here).

> [!TIP]
> **Try it — make a mount busy, then find the cause**
>
> Open a second shell into the same VM (`astrona ssh astro-section-010-module-01-playground` again) and park it inside the mount:
>
> ```sh
> cd /mnt/backup-black
> sleep 600 &
> ```
>
> Back in the first shell:
>
> ```sh
> sudo umount /mnt/backup-black        # fails: target is busy
> sudo lsof +D /mnt/backup-black
> sudo fuser -mv /mnt/backup-black
> ```
>
> Expect something like:
>
> ```text
> umount: /mnt/backup-black: target is busy.
>
> COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
> bash     4025 ubuntu  cwd    DIR  254,16     4096    2 /mnt/backup-black
>
>                      USER        PID ACCESS COMMAND
> /mnt/backup-black:    ubuntu     4025 ..c..  bash
> ```
>
> Both tools point at the second shell's `bash` (PID `4025` here — yours will differ), and `fuser`'s `..c..` shows the reason: that shell's *current directory* is inside the mount. Nothing has a file open; just standing in the directory is enough to block the unmount.

## Evicting the process that holds the mount

Sometimes the fix is gentle: if it is only a shell's working directory, running `cd` somewhere else (for example `cd ~`) releases the hold with nothing killed. Try that first.

When an actual process must be stopped, follow the **signal escalation ladder** and start with the least forceful option:

1. **`SIGTERM` (signal 15)** — the default `kill` signal. It asks the process to shut down cleanly: flush buffers, close files, exit. A well-behaved program obeys within a second or two.

   ```sh
   sudo kill 4025          # same as: kill -15 4025
   ```

2. **`SIGKILL` (signal 9)** — used only if `SIGTERM` was ignored. The kernel terminates the process immediately without letting it run any cleanup code. Unwritten data in that process is lost, but its file descriptors are closed at once, releasing the mount.

   ```sh
   sudo kill -9 4025
   ```

> [!TIP]
> **Try it — release the mount and detach it**
>
> Using the PID that `fuser` reported for your second shell:
>
> ```sh
> sudo kill <PID>
> sudo fuser -mv /mnt/backup-black     # should now print no process
> sudo umount /mnt/backup-black
> lsblk /dev/vdb
> ```
>
> Expect something like:
>
> ```text
>                      USER        PID ACCESS COMMAND
> /mnt/backup-black:
>
> NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS
> vdb  254:16   0   2G  0 disk
> ```
>
> Once no process is listed, `umount` succeeds and `lsblk` shows `vdb` with an empty mount point again — back to a detached, formatted disk.

## Reclaiming space from hidden directories

Storage work is not only setup; it is also keeping disks from filling. When `df -h` shows a mount near 100 percent, you need to find what is consuming it.

A frequent surprise is a directory whose name starts with a dot (`.trash`, `.Trash-1000`, `.cache`), created by a desktop environment or an application at the root of a mount. Names beginning with a dot are hidden from a plain `ls`, so `ls /mnt/data` can look empty while gigabytes sit in `/mnt/data/.trash`. Use `ls -la` to show dotfiles, and `du` ("disk usage") with `-sh` to total a directory's size.

> [!TIP]
> **Try it — reveal hidden space**
>
> ```sh
> sudo mount /dev/vdb /mnt/backup-black
> sudo mkdir /mnt/backup-black/.trash
> sudo dd if=/dev/zero of=/mnt/backup-black/.trash/junk bs=1M count=64
> ls /mnt/backup-black            # looks empty
> ls -la /mnt/backup-black        # .trash is visible
> du -sh /mnt/backup-black/.trash
> ```
>
> Expect something like:
>
> ```text
> total 24
> drwxr-xr-x 4 root root  4096 Aug 29 12:10 .
> drwxr-xr-x 3 root root  4096 Aug 29 12:00 ..
> drwx------ 2 root root 16384 Aug 29 12:05 lost+found
> drwxr-xr-x 2 root root  4096 Aug 29 12:10 .trash
>
> 64M     /mnt/backup-black/.trash
> ```
>
> The plain `ls` hides `.trash`; `ls -la` shows it, and `du -sh` confirms it holds the 64 MB you just wrote. Emptying such a directory (`sudo rm -rf /mnt/backup-black/.trash/*`) is how you would recover the space on a real full disk — check what is inside before deleting.

> [!WARNING]
> **Common pitfalls**
>
> - **Running `mkfs` on the wrong device.** `mkfs.ext4 /dev/vda` would wipe the running system. There is no confirmation prompt and no undo. Always run `lsblk` and match the size and mount point before formatting.
> - **Confusing `umount` with `unmount`.** The command is `umount`, with a single `n`. `unmount` is not a command.
> - **Assuming "target is busy" means a bug.** It almost always means a shell (often your own) has its working directory inside the mount, or a background job is reading a file there. `lsof +D` and `fuser -mv` tell you which; `cd ~` frequently fixes it without killing anything.
> - **Jumping straight to `kill -9`.** `SIGKILL` gives the process no chance to flush data or remove lock files. Send the default `SIGTERM` first and only escalate if the process ignores it.
> - **Trusting a plain `ls` on a full disk.** Hidden dot-directories do not show up. Use `ls -la` and `du -sh` when hunting for consumed space.
