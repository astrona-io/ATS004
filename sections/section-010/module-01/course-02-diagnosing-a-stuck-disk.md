# Part 2 — Diagnosing a Stuck Disk

> Prerequisite: [Part 1 — Discovery, Formatting & Mounting](./course-01-discovery-formatting-mounting.md). Next: [Module 2 — Partitioning Raw Storage](../module-02/course.md).

Part 1 got a disk mounted. This part covers the opposite direction: detaching it cleanly, and what to do when the kernel refuses — plus a related space-management problem, hidden directories eating a mount you cannot even see filling up.

## When a disk will not unmount

Detaching a filesystem is done with `umount` (note the spelling — one `n`), taking either the device or the mount point:

```sh
sudo umount /mnt/backup-black
```

Often this just works. But if any process has a file open under the mount, or has its working directory inside it, the kernel refuses:

```text
umount: /mnt/backup-black: target is busy.
```

### Why the kernel actually refuses

This is a safety feature, and it is enforced with a reference count, not a heuristic. Every mounted filesystem tracks how many kernel objects currently point *into* it — an open file descriptor, a process's current working directory, a running executable's binary image, a memory-mapped file, or another filesystem mounted on top of a subdirectory of this one. `umount` asks the kernel to remove the mount's table entry; the kernel checks that count first, and if it is nonzero, refuses with `EBUSY` rather than dropping references out from under a program that still expects them to resolve. Unmounting a filesystem out from under a running program would drop its unwritten data and likely crash it, so the kernel blocks the unmount until nothing is using the filesystem any more. The most common culprit is your own shell sitting inside the directory — a shell's working directory counts as "in use", exactly like an open file does.

Two tools identify what is holding a mount, and each maps onto one of those reference kinds:

- `lsof` ("list open files") lists every open file on the system; `lsof +D <dir>` narrows that to files open under a directory tree. Its output includes the command name, the process ID (PID), the user, and the exact path.
- `fuser` ("file user") reports the PIDs using a path. With `-m` it treats the argument as a whole mounted filesystem, and with `-v` it prints a readable table including an `ACCESS` column that names *which* kind of reference each process holds: `c` = the process's current directory is here, `e` = its running executable (or a shared library it loaded) is here, `f` = it has an ordinary file open here, `m` = it has a file memory-mapped (`mmap`) here. A stacked mount shows up differently again — `umount` on the lower mount fails even with `fuser` reporting nothing, because the reference is another mount-table entry, not a process; unmount the upper one first.

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
> Both tools point at the second shell's `bash` (PID `4025` here — yours will differ), and `fuser`'s `..c..` shows the reason: the `c` in the third position is the *current-directory* reference described above. Nothing has a file open (no `f`); just standing in the directory is enough to hold the reference count above zero and block the unmount.

## Evicting the process that holds the mount

Sometimes the fix is gentle: if it is only a shell's working directory, running `cd` somewhere else (for example `cd ~`) releases the hold with nothing killed. Try that first — it drops the same reference the kernel is counting, without touching the process itself.

When an actual process must be stopped, follow the **signal escalation ladder** and start with the least forceful option:

1. **`SIGTERM` (signal 15)** — the default `kill` signal. It asks the process to shut down cleanly: flush buffers, close files, exit. A well-behaved program obeys within a second or two — and in doing so, closes its own file descriptors, which is what actually drops the mount's reference count. `kill` does not force anything; it only delivers a request the process can still ignore.

   ```sh
   sudo kill 4025          # same as: kill -15 4025
   ```

2. **`SIGKILL` (signal 9)** — used only if `SIGTERM` was ignored. The kernel terminates the process immediately without letting it run any cleanup code. Unwritten data in that process is lost, but its file descriptors are closed at once by the kernel itself as part of tearing down the process, releasing the mount.

   ```sh
   sudo kill -9 4025
   ```

If neither is practical — for instance the mount is genuinely still needed by processes you cannot stop, or it is an unresponsive network filesystem — two `umount` variants exist for that situation, worth knowing even though this playground will not need them: `umount -l` ("lazy") detaches the mount from the directory tree immediately, so no *new* access can start, but defers the actual cleanup until the reference count naturally reaches zero; `umount -f` ("force") is for filesystems (typically NFS) stuck waiting on an unreachable server. Both are escape hatches, not substitutes for finding and stopping the actual culprit.

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
> Once no process is listed, the reference count is zero, `umount` succeeds, and `lsblk` shows `vdb` with an empty mount point again — back to a detached, formatted disk.

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
> - **Confusing `umount` with `unmount`.** The command is `umount`, with a single `n`. `unmount` is not a command.
> - **Assuming "target is busy" means a bug.** It almost always means a shell (often your own) has its working directory inside the mount, or a background job is reading a file there. `lsof +D` and `fuser -mv` tell you which reference kind is held; `cd ~` frequently fixes it without killing anything.
> - **Jumping straight to `kill -9`.** `SIGKILL` gives the process no chance to flush data or remove lock files. Send the default `SIGTERM` first and only escalate if the process ignores it.
> - **Reaching for `umount -f`/`-l` before checking `lsof`/`fuser`.** They mask the cause instead of fixing it, and `-l`'s deferred cleanup can surprise you later if you assumed the unmount was fully complete.
> - **Trusting a plain `ls` on a full disk.** Hidden dot-directories do not show up. Use `ls -la` and `du -sh` when hunting for consumed space.

> *`umount` fails on a reference count, not a guess — `lsof`/`fuser` tell you exactly which kind of reference (open file, cwd, executable, mmap, or a stacked mount) is holding it at zero.*

## Reference

- `man umount` — including the `-l` (lazy) and `-f` (force) flags introduced above.
- `man fuser` — the full `ACCESS` column legend (`c`, `e`, `f`, `m`, and more).
- `man lsof` — output field reference for `FD` and `TYPE`.
- `man du` — `-x` to stay on one filesystem, useful once Section 080 covers directory auditing in depth.
