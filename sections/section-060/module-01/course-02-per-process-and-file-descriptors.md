# Per-Process Directories & Open File Descriptors

Every `/proc` file is a generator function, not stored bytes. This part applies the same idea to processes. Every running process gets a directory, `/proc/<PID>/`, and every value inside it comes from the kernel's live record of that one process.

## Per-process directories: `/proc/<PID>/`

Think of the crew roster. Each crew member has a badge number, the process ID (PID). `/proc/<PID>/` is the status screen for the crew member with that badge. This section shows where the screen comes from and what the first files in it tell you.

### Why the directory comes and goes

The kernel keeps one internal record, called a `task_struct`, for each running process. procfs shows each record as a directory of generator files. Nothing creates the directory when the process starts, and nothing deletes it when the process ends. It is a **view** of the record. While the record exists, `ls /proc/` lists the PID. The moment the kernel frees the record, the directory is gone. There is no cleanup step and no stale entry.

### What is inside

`cmdline` holds the command and arguments the process started with. A null byte (`\0`) separates them instead of a space, because that is how the list sits in the process's own memory. Piping through `tr '\0' ' '` makes it readable. `exe` and `cwd` are symlinks to the running program and to its working directory.

<!-- astrona:playground:renew -->

### See it in your playground

Start the demo process and read how it was launched. Replace `<PID>` with the number `start-demo-proc` prints.

```sh
start-demo-proc
PID=<PID>
cat /proc/$PID/cmdline | tr '\0' ' '; echo
ls -l /proc/$PID/ | head
```

Expect something like this:

```text
demo process PID: 1789

tail -F /srv/demo/one.log /srv/demo/two.log

-r--r--r-- 1 ubuntu ubuntu 0 Aug 29 12:05 cmdline
lrwxrwxrwx 1 ubuntu ubuntu 0 Aug 29 12:05 cwd -> /home/ubuntu
lrwxrwxrwx 1 ubuntu ubuntu 0 Aug 29 12:05 exe -> /usr/bin/tail
dr-x------ 1 ubuntu ubuntu 0 Aug 29 12:05 fd
...
```

`cmdline` shows the exact command with the two log paths. The targets of `exe` and `cwd` are generated on every read from the process's own state. That is why they stay current even if the process changes directory later.

## Open file descriptors: `/proc/<PID>/fd/`

A crew member keeps open lines to items in the hold: files, sockets and pipes. Each line has a number. This section shows how to list those lines and why counting them finds a leak.

### The descriptor table

Every process has a file descriptor table, a kernel array where each used slot points at one open item. `/proc/<PID>/fd/` shows that table as a directory with one symlink per used slot. The link name is the slot number, and the link target is whatever the item is right now. Slots `0`, `1` and `2` are standard input, output and error. Higher numbers are whatever the process opened since.

### Catching a leak

Counting the entries (`ls | wc -l`) tells you how many items the process holds open right now. A program that opens files or sockets and never closes them makes this count grow until it hits its limit. Then it fails with "Too many open files". This is a **file-descriptor leak**. The count is the live table, so there is nothing to cache or go stale.

### See it in your playground

List the descriptors, count them, stop the process, and look again.

```sh
ls -l /proc/$PID/fd/
ls /proc/$PID/fd/ | wc -l
kill $PID
ls /proc/$PID/
```

Expect something like this:

```text
lrwx------ 1 ubuntu ubuntu 64 Aug 29 12:05 0 -> /dev/pts/0
l-wx------ 1 ubuntu ubuntu 64 Aug 29 12:05 1 -> /tmp/demo-proc.out
l-wx------ 1 ubuntu ubuntu 64 Aug 29 12:05 2 -> /tmp/demo-proc.out
lr-x------ 1 ubuntu ubuntu 64 Aug 29 12:05 3 -> /srv/demo/one.log
lr-x------ 1 ubuntu ubuntu 64 Aug 29 12:05 4 -> /srv/demo/two.log
5
ls: cannot access '/proc/1789/': No such file or directory
```

The demo process holds 5 descriptors: standard input, output and error, plus the two logs it follows. A leaking process would show a count that climbs into the thousands. After `kill`, the kernel frees the record and the directory disappears in the same instant.

## Common pitfalls

> [!WARNING]
> - **Reading `cmdline` without translating nulls.** `cat /proc/<PID>/cmdline` looks like the arguments run together. They are null-separated. Pipe through `tr '\0' ' '`.
> - **Assuming every `fd` entry is a file.** Many are sockets (`socket:[12345]`), pipes (`pipe:[...]`) or `anon_inode` objects. A leak often shows as thousands of `socket:` links.
> - **A stale PID.** The kernel reuses PIDs. If `/proc/<PID>` shows an unexpected process, the one you tracked has exited. Check `cmdline` again.
> - **Needing root.** You do not need it for your own processes. Reading another user's `/proc/<PID>/fd/` needs `sudo`.
