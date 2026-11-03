# Diagnosing a Stuck Disk

Getting a disk mounted is only half the job, astronaut. Sooner or later you must undock it again. Usually that just works, but sometimes the kernel refuses. Here you learn why it refuses, how to find the crew member who is still inside the hold, and how to send them out safely.

## When a disk will not unmount

Undocking a hold sounds simple, and most of the time it is. This section shows the command, the error you get when the hold is busy, and the two tools that tell you who is keeping it busy.

### Unmount with `umount`

Detaching a filesystem is done with `umount` (note the spelling: one `n`). You can give it the device or the mount point.

The commands below need the 2 GB disk formatted with ext4 and mounted at `/mnt/backup-black`. In a fresh playground the disk is raw again, so format and mount it first. Confirm the disk name with `lsblk` before you run `mkfs.ext4`:

<!-- astrona:playground:renew -->

```sh
sudo mkfs.ext4 /dev/vdb
sudo mkdir -p /mnt/backup-black
sudo mount /dev/vdb /mnt/backup-black
```

Now this is the command that detaches it:

```sh
sudo umount /mnt/backup-black
```

Often this just works. But if any process has a file open under the mount, or has its working directory inside it, the kernel refuses:

```text
umount: /mnt/backup-black: target is busy.
```

If you just ran `umount` and it worked, mount the disk again with `sudo mount /dev/vdb /mnt/backup-black` before you go on.

### Why the kernel refuses

A **busy mount** is a hold that cannot undock while crew are still inside. A **process** is one crew member doing one job, and its **process ID (PID)** is the crew member's badge number.

The kernel enforces this with a count, not a guess. Every mounted filesystem keeps track of how many things in the kernel point into it right now:

- an open file (a **file descriptor**, which is a crew member's open line to one item in the hold),
- a process's current working directory,
- the program file of a running process,
- a memory-mapped file (a file the process has loaded into its memory with `mmap`),
- another filesystem mounted on a directory inside this one.

`umount` asks the kernel to remove the mount's table entry. The kernel checks the count first. If it is not zero, the kernel refuses with the error code `EBUSY` ("device or resource busy"). Pulling the filesystem away from a running program would lose its unwritten data and could crash it, so the kernel waits until nothing uses the filesystem.

The most common cause is your own shell standing inside the directory. A shell's working directory counts as "in use", exactly like an open file.

### Two tools that find the holder

Two tools show what holds a mount. Each one maps to the kinds of hold listed above.

- `lsof` ("list open files") lists every open file on the system. `lsof +D <dir>` narrows that to files open under one directory tree. Its output shows the command name, the PID, the user and the exact path.
- `fuser` ("file user") reports the PIDs that use a path. With `-m` it treats the path as a whole mounted filesystem. With `-v` it prints a readable table with an `ACCESS` column that says which kind of hold each process has:
  - `c`: the process's current directory is here,
  - `e`: its running program (or a shared library it loaded) is here,
  - `f`: it has an ordinary file open here,
  - `m`: it has a file memory-mapped here.

A stacked mount looks different. `umount` on the lower mount fails even when `fuser` lists nothing, because the hold is another entry in the mount table, not a process. Unmount the upper mount first. `man fuser` lists every letter of the `ACCESS` column, and `man lsof` explains the `FD` and `TYPE` columns.

### See it in your playground

Open a second shell into the same ship with `astrona ssh section-010-module-01-playground`, and park it inside the mount:

```sh
cd /mnt/backup-black
sleep 600 &
```

Back in the first shell, try to unmount, then ask both tools who is inside:

```sh
sudo umount /mnt/backup-black        # fails: target is busy
sudo lsof +D /mnt/backup-black
sudo fuser -mv /mnt/backup-black
```

Expect something like:

```text
umount: /mnt/backup-black: target is busy.

COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
bash     4025 ubuntu  cwd    DIR  254,16     4096    2 /mnt/backup-black

                     USER        PID ACCESS COMMAND
/mnt/backup-black:    ubuntu     4025 ..c..  bash
```

Your list will likely also show a `sleep` line with the same `cwd`, because the background job starts in the shell's directory. On Ubuntu 24.04, `fuser` may also print a `kernel mount` line for the mount itself; that line is not a process.

Both tools point at the second shell's `bash` (PID `4025` here; yours will differ). In `fuser`'s `..c..`, the `c` in the third place gives the reason: a current-directory hold. Nothing has a file open (no `f`). Just standing in the directory keeps the count above zero and blocks the unmount.

## Evict the process that holds the mount

Once you know which crew member is inside, you have to get them out. This section starts with the gentlest fix and climbs, step by step, to the strongest one.

### Try the gentle fix first

If the hold is only a shell's working directory, run `cd` somewhere else (for example `cd ~`) in that shell. That drops the same hold the kernel is counting, and nothing gets killed.

### The signal ladder

When a process really must stop, use the **signal escalation ladder**. A **signal** is an order to a crew member. Start with the mildest order.

1. **`SIGTERM` (signal 15)** means "finish up and leave". It is the default signal of `kill`. It asks the process to shut down cleanly: write out its buffers, close its files and exit. A well-behaved program obeys within a second or two. By closing its own file descriptors, it drops the mount's count. `kill` forces nothing here; the process could still ignore the request.

   ```sh
   sudo kill 4025          # same as: kill -15 4025
   ```

2. **`SIGKILL` (signal 9)** means "out, now". Use it only if the process ignored `SIGTERM`. The kernel ends the process at once and lets it run no cleanup code. Any unwritten data in that process is lost, but the kernel itself closes its file descriptors as it removes the process, and that releases the mount.

   ```sh
   sudo kill -9 4025
   ```

Replace `4025` with the PID that `lsof` or `fuser` showed you.

### When you cannot stop the process

Sometimes neither signal is practical. The processes may still need the mount, or it may be a network filesystem whose server has stopped answering. `umount` has two options for that. Your playground will not need them, but you should know them:

- `umount -l` ("lazy") detaches the mount from the tree at once, so no new access can start. The real cleanup waits until the count reaches zero on its own.
- `umount -f` ("force") is for filesystems, usually NFS, that are stuck waiting for a server that does not answer.

Both are escape hatches. They do not replace finding and stopping the real cause. `man umount` describes both options.

### See it in your playground

Use the PID that `fuser` reported for your second shell, then check, unmount and look at the disk again:

```sh
sudo kill <PID>
sudo fuser -mv /mnt/backup-black     # should now print no process
sudo umount /mnt/backup-black
lsblk /dev/vdb
```

Expect something like:

```text
                     USER        PID ACCESS COMMAND
/mnt/backup-black:

NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS
vdb  254:16   0   2G  0 disk
```

An interactive `bash` ignores the polite `SIGTERM`, and the `sleep` job also stands in the directory. If `fuser` still lists a process, run `cd ~` in the second shell and stop the `sleep` there with `kill %1`.

Once no process is listed, the count is zero and `umount` succeeds. `lsblk` shows `vdb` with an empty mount point again: a formatted disk, detached from the tree.

## Common pitfalls

> [!WARNING]
> - **Confusing `umount` with `unmount`.** The command is `umount`, with a single `n`. `unmount` is not a command.
> - **Assuming "target is busy" means a bug.** It almost always means a shell (often your own) has its working directory inside the mount, or a background job is reading a file there. `lsof +D` and `fuser -mv` tell you which kind of hold it is, and `cd ~` often fixes it without killing anything.
> - **Jumping straight to `kill -9`.** `SIGKILL` gives the process no chance to write out data or remove lock files. Send the default `SIGTERM` first, and only climb the ladder if the process ignores it.
> - **Reaching for `umount -f` or `umount -l` before checking `lsof` or `fuser`.** They hide the cause instead of fixing it, and the delayed cleanup of `-l` can surprise you later if you thought the unmount was complete.

> *`umount` fails on a count, not a guess: `lsof` and `fuser` tell you exactly which kind of hold (open file, working directory, program file, memory map or a stacked mount) keeps it above zero.*

## Your mission: Diagnosing & Evicting a Busy Mount

You can now find the process that keeps a mount busy and stop it safely. The mission gives you a mounted disk held open by a background process: find it, stop it without harming anything else, and unmount the disk.

The mission runs on its own training ship. A playground cannot be paused, so remove it first to free memory; it always starts clean again:

```sh
astrona destroy section-010-module-01-playground
```

Then start the mission and connect to it:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-010/module-01/labs/lab-02
astrona ssh ats-004-lab-019
```

Read the task in [`question.md`](./labs/lab-02/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-01/labs/lab-02
```

When the mission is done, remove it and start a fresh playground:

```sh
astrona destroy ats-004-lab-019
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-010/module-01/playground
```
