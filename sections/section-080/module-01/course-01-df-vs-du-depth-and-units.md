# Part 1 — df vs du, and Reading du at a Sensible Depth

> Prerequisite: [Module landing page](./course.md). Next: [Part 2 — Staying on One Filesystem & Allocated vs Apparent Size](./course-02-one-filesystem-and-apparent-size.md).

`df` and `du` answer two different questions, and the gap between their answers is where real capacity incidents hide. This part settles what each one actually reads, and gets `du`'s raw wall of numbers down to something you can act on.

## `df` says "full", `du` says "what"

`df` reads each filesystem's own free-space counters — a handful of numbers the filesystem driver already tracks, so `df` returns instantly regardless of how much data is on disk. `du` walks a directory tree, `stat`-ing every entry it can reach and summing the blocks each one occupies — slower, and its speed scales with the number of files, but it can point at a specific subdirectory.

> As an analogy: `df` is the weight printed on the side of a shipping container; `du` is wheeling a scale into the container and weighing each pallet to find the heavy one. The analogy breaks down because `du` and the container label can legitimately disagree — deleted-but-still-open files and filesystem overhead count toward `df` but are invisible to a `du` tree walk.

That disagreement is not a rounding error — it has one specific, common cause worth naming precisely. A file on disk is really two separate things: a **directory entry** (the name, pointing at an inode) and the **inode itself** (the metadata and block list the kernel actually allocates space for). `rm` only ever removes the directory entry — it decrements the inode's *link count*. The kernel does not reclaim the inode's blocks while the link count is above zero, **or** while any process still holds the file open (its *open-file reference count* is above zero). A process that opened a huge log file and then had that file `rm`'d out from under it — a common pattern for "atomic" log rotation — keeps writing into blocks that no longer have a name.

`du` walks directory entries. An unlinked-but-still-open file has none, so `du` cannot see it, cannot charge its blocks to any directory, and reports nothing for it. `df` reads the filesystem's live allocation counters, which still show those blocks as used — because they are. The filesystem does not free them until the link count **and** the open count both reach zero. This single mechanism — "unlinked but open" — is the most common reason a server reports `df` at 95% while `du -x /` only adds up to 60%, and it is exactly why Part 2's pitfall list points you at `lsof +L1` rather than another `du` flag when the numbers don't reconcile.

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
> The first line is the total for `/opt` itself; the rest are its immediate children, largest first. `/opt/reports` (the 256 MiB file) dominates; `/opt/archive` is tiny despite holding a "512 MiB" sparse file — Part 2 covers why. Without `-d 1` you would get a line for every file under `/opt/logs` too.

> *`df` reads a counter; `du` walks a tree it can see — and "unlinked but open" is the gap between what the counter counts and what the tree walk can reach.*

## Reference

- `man du` — the `-d`/`--max-depth`, `-h`, and `--apparent-size` (covered in Part 2) flags in full.
- `man lsof` — `+L1` lists open files with a link count of 1 or less; the direct tool for finding an unlinked-but-open file.
