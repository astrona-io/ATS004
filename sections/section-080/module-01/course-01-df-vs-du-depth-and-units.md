# df vs du, and Reading du at a Sensible Depth

`df` and `du` answer two different questions. The gap between their answers is where real capacity incidents hide. This part shows what each command reads, and how to turn the raw wall of numbers from `du` into a short, sorted list you can act on.

## `df` says "full", `du` says "what"

Astronaut, think of a cargo hold. `df` reads the gauge on the hatch: it tells you how full the whole hold is. `du` wheels a scale along the shelves and weighs every crate, so it can point at the heavy one.

`df` reads counters that the filesystem already keeps, so it answers at once, however much data the disk holds. `du` walks a directory tree and asks about every entry it can reach. It is slower, and its speed depends on the number of files. In return, it can point at one directory.

The two can disagree, and that is not a rounding error. A file is really two things: a **directory entry** (the name) and an **inode** (the cargo tag that holds the owner, the size and the list of blocks). The command `rm` removes only the name. The kernel frees the blocks only when no names are left and no process still holds the file open.

Picture a crew member who opened a huge log file, and then someone ran `rm` on it. The crew member keeps writing into blocks that no longer have a name. `du` walks names, so it cannot see the file. `df` reads the live counters, which still count those blocks as used. This "deleted but still open" case is the most common reason a server shows `df` at 95% while `du` adds up to only 60%. The command `lsof +L1` lists such files.

## `du` with depth and units

A bare `du` prints a line for every directory, counted in kilobytes. That is unreadable on a real system. Two options fix it. The option `-h` prints human units (K, M, G). The option `-d 1` (maximum depth 1) prints only the immediate children and the grand total, and it rolls everything deeper into those lines.

Pipe the result into `sort -hr`. The `-h` makes `sort` understand that `1.4G` is bigger than `900M`, and `-r` puts the biggest first.

<!-- astrona:playground:renew -->

### See it in your playground

Rank the subdirectories of `/opt`:

```sh
du -h -d 1 /opt | sort -hr
```

Expect something like this:

```text
257M    /opt
256M    /opt/reports
812K    /opt/logs
20K     /opt/archive
```

The first line is the total for `/opt` itself. The other lines are its immediate children, largest first. `/opt/reports` holds the 256 MiB file, so it leads. `/opt/archive` is tiny even though it holds a "512 MiB" file. The reason is a sparse file, which you will meet in this module. Without `-d 1` you would also get one line for every file under `/opt/logs`.

To audit one directory and print only its total, use `-s`:

```sh
du -sh /opt/reports
```

This prints a single line with the total size of `/opt/reports`.

## Common pitfalls

> [!WARNING]
> - **`sort` without `-h`.** A plain `sort -r` compares text, so `9M` lands above `10G`. Use `sort -hr`.
> - **Assuming `df` and `du` must match.** They count different things. A gap is a clue, not a bug.
> - **Reading `du` without enough privilege.** A normal user cannot enter some directories, so `du` undercounts and prints "Permission denied". Run audits with `sudo`.
