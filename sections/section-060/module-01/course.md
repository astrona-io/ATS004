# The Process Blueprint: Inside /proc

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-060/module-01/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-060/module-01/playground
> astrona destroy section-060-module-01-playground
> ```

`/proc` is a directory that is not on any disk. The kernel generates its contents on the fly: each time you read a file under `/proc`, the kernel assembles the answer from its own live data structures and hands it back as text. It is the plainest possible interface to what the kernel knows — no special tools, just `cat`, `grep`, and `ls`.

This module covers the two useful halves of `/proc`: the system-wide files at the top level (memory, CPU, kernel command line) and the per-process directories named by PID, where `cmdline` and `fd/` let you see exactly how a process was started and what it currently has open.

## Learning objectives

After this module you can:

- Explain what a pseudo-filesystem is and why `/proc` files report a size of 0.
- Read system-wide facts from `/proc/meminfo`, `/proc/cpuinfo`, and `/proc/cmdline`.
- Find a running process's directory under `/proc/<PID>/` and read its launch command from `cmdline`.
- List and count a process's open file descriptors under `/proc/<PID>/fd/`.
- Describe how `/proc/<PID>/fd/` is used to find a file-descriptor leak.

## Before you start

You should be comfortable with `cat`, `ls -l`, `grep`, and reading command output; `tr` and `wc` appear too and are explained where used.

The linked playground gives you an Ubuntu server VM. Almost nothing here needs `sudo` — `/proc` is world-readable. A helper command `start-demo-proc` launches a long-lived process (a `tail -F` on two seeded log files) and prints its PID, giving you a process to inspect. Run the command blocks below in that VM after `astrona ssh section-060-module-01-playground`.

## `/proc` is a live view, not files

> As an analogy: `/proc` is a car's instrument cluster. The fuel gauge is not a stored document; it is a needle wired to a live sensor. Reading `/proc/meminfo` likewise triggers the kernel to sample its current state and render it. The analogy breaks down because you can also *write* to some `/proc` files to change kernel behaviour — a gauge you can push on — which the next module covers.

Because the content is generated on demand, most `/proc` files report a length of 0 in `ls -l`: there is no stored data to measure. The bytes only exist while you are reading them.

> [!TIP]
> **Try it — zero bytes, real content**
>
> ```sh
> ls -l /proc | head
> stat -c '%s bytes  %n' /proc/meminfo
> head -n 3 /proc/meminfo
> ```
>
> Expect something like:
>
> ```text
> dr-xr-xr-x  9 root root 0 Aug 29 12:00 1
> dr-xr-xr-x  9 root root 0 Aug 29 12:00 1234
> -r--r--r--  1 root root 0 Aug 29 12:00 meminfo
> ...
> 0 bytes  /proc/meminfo
> MemTotal:        2019684 kB
> MemAvailable:    1650000 kB
> ```
>
> `stat` says `/proc/meminfo` is 0 bytes, yet `head` prints real numbers. The numbered directories at the top (`1`, `1234`, …) are one per running process.

## System-wide files

The top level of `/proc` holds global state. `/proc/meminfo` is the full, unrounded memory accounting — `free` is essentially a formatter over it. `/proc/cpuinfo` describes each CPU. `/proc/cmdline` is the exact string the bootloader passed to the kernel.

> [!TIP]
> **Try it — the numbers behind `free`**
>
> ```sh
> grep -E '^(MemTotal|MemAvailable|MemFree):' /proc/meminfo
> free -k | head -n 2
> ```
>
> Expect something like:
>
> ```text
> MemTotal:        2019684 kB
> MemFree:          140000 kB
> MemAvailable:    1650000 kB
>
>                total        used        free      shared  buff/cache   available
> Mem:         2019684      ...          140000      ...        ...       1650000
> ```
>
> The `total` and `available` columns from `free -k` are the same numbers as `MemTotal` and `MemAvailable` in `/proc/meminfo`. `free` reads this file and lays it out; the file is the source.

## Per-process directories: `/proc/<PID>/`

Every process has a directory `/proc/<PID>/`. Inside, `cmdline` holds the argument vector the process was started with, using a null byte (`\0`) between arguments instead of a space. Piping it through `tr '\0' ' '` makes it readable.

> [!TIP]
> **Try it — how a process was launched**
>
> ```sh
> start-demo-proc
> PID=<the number it printed>
> cat /proc/$PID/cmdline | tr '\0' ' '; echo
> ls -l /proc/$PID/ | head
> ```
>
> Expect something like:
>
> ```text
> demo process PID: 1789
>
> tail -F /srv/demo/one.log /srv/demo/two.log
>
> -r--r--r-- 1 ubuntu ubuntu 0 Aug 29 12:05 cmdline
> lrwxrwxrwx 1 ubuntu ubuntu 0 Aug 29 12:05 cwd -> /home/ubuntu
> lrwxrwxrwx 1 ubuntu ubuntu 0 Aug 29 12:05 exe -> /usr/bin/tail
> dr-x------ 1 ubuntu ubuntu 0 Aug 29 12:05 fd
> ...
> ```
>
> `cmdline` shows the exact command (the two log paths it is tailing). `exe` links to the running binary and `cwd` to its working directory — the process's blueprint, straight from the kernel.

## Open file descriptors: `/proc/<PID>/fd/`

`/proc/<PID>/fd/` contains one symlink per open file descriptor, named by its number. `0`, `1`, and `2` are standard input, output, and error; higher numbers are files, sockets, and pipes the process opened. Counting them (`ls | wc -l`) is how you catch a **file-descriptor leak**: a program that opens files or sockets and never closes them will show a steadily growing count and eventually hit its limit with "Too many open files".

> [!TIP]
> **Try it — list and count descriptors, then watch the directory vanish**
>
> ```sh
> ls -l /proc/$PID/fd/
> ls /proc/$PID/fd/ | wc -l
> kill $PID
> ls /proc/$PID/
> ```
>
> Expect something like:
>
> ```text
> lrwx------ 1 ubuntu ubuntu 64 Aug 29 12:05 0 -> /dev/pts/0
> l-wx------ 1 ubuntu ubuntu 64 Aug 29 12:05 1 -> /tmp/demo-proc.out
> l-wx------ 1 ubuntu ubuntu 64 Aug 29 12:05 2 -> /tmp/demo-proc.out
> lr-x------ 1 ubuntu ubuntu 64 Aug 29 12:05 3 -> /srv/demo/one.log
> lr-x------ 1 ubuntu ubuntu 64 Aug 29 12:05 4 -> /srv/demo/two.log
>
> 5
>
> ls: cannot access '/proc/1789/': No such file or directory
> ```
>
> The demo process holds 5 descriptors — stdio plus the two log files it tails. On a leaking process this count would climb into the thousands. After `kill`, `/proc/$PID/` is gone immediately: the directory only existed because the process did.

> [!WARNING]
> **Common pitfalls**
>
> - **Expecting `/proc` files to have a size.** Almost all report 0 bytes because the content is generated at read time. Use `cat`/`grep`, not the size, to see what is there.
> - **Reading `cmdline` without translating nulls.** `cat /proc/<PID>/cmdline` looks like the arguments are run together. They are null-separated; pipe through `tr '\0' ' '`.
> - **Assuming every `fd` entry is a file.** Many are sockets (`socket:[12345]`), pipes (`pipe:[...]`), or `anon_inode` objects. A leak often shows as thousands of `socket:` links.
> - **A stale PID.** PIDs are reused. If `/proc/<PID>` shows an unexpected process, the one you were tracking has exited and the number was recycled. Re-check with `ps` or by reading `cmdline`.
> - **Needing root.** You do not, for your own processes or world-readable global files. Reading another user's `/proc/<PID>/fd/` or `environ` does require `sudo`.
