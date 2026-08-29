# Directory Capacity Auditing

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-080/module-01/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-080/module-01/playground
> astrona destroy section-080-module-01-playground
> ```

`df -h` tells you a filesystem is full. It does not tell you *what* filled it. To find the oversized log, backup, or cache directory, you measure consumption from the top down with `du` — and you have to keep `du` from wandering into other filesystems and pseudo-filesystems while it works.

This module covers `du` with a sensible depth and units, sorting its output, the `-x` flag that keeps it on one filesystem, and why `du`'s numbers sometimes disagree with `df`'s.

## Learning objectives

After this module you can:

- Explain the difference between what `df` reports and what `du` reports.
- Run `du -h -d 1` on a directory and sort the result largest-first with `sort -hr`.
- Use `du -x` to keep the scan on a single filesystem and say why that matters at `/`.
- Explain why `du` (allocated blocks) can differ from `--apparent-size` and from `df`.

## Before you start

You should be comfortable with pipes and reading sizes like `256M` / `1.4G`.

The linked playground gives you an Ubuntu server VM with a second filesystem mounted at `/data` (so `du -x` has a boundary to hit), and seeded files on the root filesystem: `/opt/reports/big-real.bin` (256 MiB of real blocks), `/opt/archive/sparse.img` (512 MiB apparent, near-zero on disk), and `/opt/logs/` (200 tiny files). Run the command blocks below in that VM after `astrona ssh section-080-module-01-playground`.

## `df` says "full", `du` says "what"

`df` reads each filesystem's own free-space counters — fast, whole-filesystem totals. `du` walks a directory tree and adds up what it finds — slower, but it can point at a specific subdirectory.

> As an analogy: `df` is the weight printed on the side of a shipping container; `du` is wheeling a scale into the container and weighing each pallet to find the heavy one. The analogy breaks down because `du` and the container label can legitimately disagree — deleted-but-still-open files and filesystem overhead count toward `df` but are invisible to a `du` tree walk.

## `du` with depth and units

Bare `du` prints a line for every directory in the tree, in kilobytes — unreadable at any scale. Two options fix that: `-h` for human units (K/M/G), and `-d 1` (max depth 1) to print only the immediate children plus the grand total, rolling up everything deeper.

Pipe into `sort -hr` to rank them: `-h` makes `sort` understand `1.4G > 900M`, and `-r` puts the biggest at the top.

> [!TIP]
> **Try it — rank the subdirectories of `/opt`**
>
> ```sh
> du -h -d 1 /opt | sort -hr
> ```
>
> Expect something like:
>
> ```text
> 257M    /opt
> 256M    /opt/reports
> 812K    /opt/logs
> 20K     /opt/archive
> ```
>
> The first line is the total for `/opt` itself; the rest are its immediate children, largest first. `/opt/reports` (the 256 MiB file) dominates; `/opt/archive` is tiny despite holding a "512 MiB" sparse file — more on that below. Without `-d 1` you would get a line for every file under `/opt/logs` too.

## Staying on one filesystem: `-x`

At `/`, a plain `du` is dangerous. The root of a server is a mosaic of mounted filesystems: the local root disk, network shares under `/mnt`, and pseudo-filesystems like `/proc` and `/sys` that are kernel interfaces, not storage. A `du -h -d 1 /` walks into all of them — it will try to size a remote NFS share over the wire, and it will churn through `/proc` producing meaningless numbers and permission errors.

`du -x` (`--one-file-system`) stops at every mount point. When the walk reaches `/data`, `/proc`, or an NFS mount, `du` does not descend. You get only what is actually on the filesystem you started on.

> [!TIP]
> **Try it — audit just the root filesystem**
>
> ```sh
> du -hx -d 1 / | sort -hr
> ```
>
> Expect something like:
>
> ```text
> 3.1G    /
> 1.9G    /usr
> 480M    /var
> 257M    /opt
> 0       /data
> 0       /proc
> ```
>
> `/data` and `/proc` show `0` — `-x` refused to cross into them, so they contribute nothing. Drop the `x` and rerun: `/data` jumps to ~400 MiB and `/proc` spews errors. Only the `-x` form is a safe, accurate answer to "what is filling the root disk?".

## Allocated blocks versus apparent size

By default `du` reports **disk space actually allocated**, in filesystem blocks — not the file's logical length. The two differ for **sparse files**: a file created at 512 MiB but never fully written (a VM image, a preallocated database file) has a large apparent size but only a few blocks on disk. `du --apparent-size` reports the logical length instead.

This is also one reason `du` and `df` disagree. Others: `df` counts space held by files that have been deleted while a process still has them open (`du` cannot see those — they have no directory entry), and `df` includes filesystem metadata overhead.

> [!TIP]
> **Try it — the sparse file two ways**
>
> ```sh
> du -h /opt/archive/sparse.img
> du -h --apparent-size /opt/archive/sparse.img
> ls -lh /opt/archive/sparse.img
> ```
>
> Expect something like:
>
> ```text
> 0       /opt/archive/sparse.img
> 512M    /opt/archive/sparse.img
> -rw-r--r-- 1 root root 512M ... /opt/archive/sparse.img
> ```
>
> Default `du` says ~0 — that is how much disk the file really occupies. `--apparent-size` and `ls -lh` say 512M — the logical size. When a capacity audit and a directory listing disagree wildly, a sparse file is a common cause.

> [!WARNING]
> **Common pitfalls**
>
> - **`du` at `/` without `-x`.** It descends into `/proc`, `/sys`, `/dev`, and every network mount — slow, noisy, and inaccurate. Always `du -x` when auditing a filesystem from its root.
> - **Reading `du` without enough privilege.** As a normal user, `du` cannot enter directories you lack permission for and undercounts, printing "Permission denied" lines. Run capacity audits with `sudo`.
> - **`sort` without `-h`.** `sort -r` alone sorts `9M` above `10G` because it compares text. Use `sort -hr` so the units are understood.
> - **Assuming `du` and `df` must match.** Deleted-but-open files, sparse files, reserved blocks, and metadata all make them differ legitimately. A large gap with no sparse files often means a deleted file still held open — check `lsof +L1`.
> - **Expecting `du` to follow symlinks.** It does not, by default — a symlinked directory counts as the tiny link, not its target. That is usually what you want for a capacity audit.
