# Part 2 — Per-Process Directories & Open File Descriptors

> Prerequisite: [Part 1 — /proc as a Live View & System-wide Files](./course-01-live-view-and-system-wide-files.md). Next: [Module landing page](./course.md).

Part 1 established that every `/proc` file is a generator function, not stored bytes. This part applies that same mechanism to processes: every running process gets a directory, `/proc/<PID>/`, and every value inside it — including the list of what the process currently has open — is generated from the kernel's live record of that one process, not written anywhere.

## Per-process directories: `/proc/<PID>/`

`/proc/<PID>/` exists because the kernel keeps one `task_struct` (its internal record of a process) per running process, and procfs exposes each `task_struct` as a directory of generator files. The directory does not get created by anything at process-start time and deleted by anything at process-exit — it is a **view** of the `task_struct`'s existence: as long as the struct exists, `ls /proc/` shows the PID; the moment the kernel frees it, the directory is simply no longer there to list. No cleanup step, no stale entry to garbage-collect.

Inside, `cmdline` holds the argument vector the process was started with, using a null byte (`\0`) between arguments instead of a space — because that is literally how `argv` is laid out in the process's own memory, and `cmdline` is a direct read of it, not a reformatted copy. Piping it through `tr '\0' ' '` makes it readable.

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
> `cmdline` shows the exact command (the two log paths it is tailing). `exe` and `cwd` are symlinks whose *targets* are generated on read from the process's own kernel state (which binary it executed, what directory it's in) — not stored strings, which is why they're always current even if the process later changes its working directory.

## Open file descriptors: `/proc/<PID>/fd/`

Every process has a file descriptor table — a kernel-maintained array where each occupied slot points at an open file object. `/proc/<PID>/fd/` is that table rendered as a directory: one symlink per occupied slot, named by its number, with the symlink's target generated from whatever the file object currently is. `0`, `1`, and `2` are standard input, output, and error; higher numbers are whatever the process opened since — regular files, sockets, pipes.

Because each entry is regenerated from the live table on every read, counting them (`ls | wc -l`) is a direct, real-time read of "how many things does this process currently have open" — which is exactly how you catch a **file-descriptor leak**: a program that opens files or sockets and never closes them grows this count monotonically, eventually hitting its resource limit and failing with "Too many open files". There is nothing to cache or go stale; the count is the table, this second.

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
> The demo process holds 5 descriptors — stdio plus the two log files it tails. On a leaking process this count would climb into the thousands, all reflected live with no polling delay. After `kill`, `task_struct` is freed and `/proc/$PID/` disappears in the same instant — confirming Part 1's rule: the directory was never a stored thing to clean up, only a view of something that stopped existing.

> [!WARNING]
> **Common pitfalls**
>
> - **Expecting `/proc` files to have a size.** Almost all report 0 bytes because the content is generated at read time (Part 1). Use `cat`/`grep`, not the size, to see what is there.
> - **Reading `cmdline` without translating nulls.** `cat /proc/<PID>/cmdline` looks like the arguments are run together. They are null-separated, straight from the process's own `argv` layout; pipe through `tr '\0' ' '`.
> - **Assuming every `fd` entry is a file.** Many are sockets (`socket:[12345]`), pipes (`pipe:[...]`), or `anon_inode` objects — anything the file descriptor table can point at. A leak often shows as thousands of `socket:` links, not open files.
> - **A stale PID.** PIDs are reused once a `task_struct` is freed and its number returns to the pool. If `/proc/<PID>` shows an unexpected process, the one you were tracking has exited. Re-check with `ps` or by reading `cmdline`.
> - **Needing root.** You do not, for your own processes or world-readable global files — procfs applies normal permission checks per file, same as any filesystem. Reading another user's `/proc/<PID>/fd/` or `environ` does require `sudo`.

## Reference

- `man 5 proc` — the `/proc/<PID>/` section documents every per-process file, including several this part didn't cover (`status`, `maps`, `limits`).
- `man lsof` — a higher-level tool that walks every process's `fd/` for you; useful once you're auditing more than one PID at a time.
