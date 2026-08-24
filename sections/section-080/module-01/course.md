# Chapter 11: The Map and the Metal: Filesystem Hierarchy and Directory Sizing

Every time you log into a Linux system, you are navigating an organized, standardized map called the **Filesystem Hierarchy Standard (FHS)**. This map ensures that whether you are on an Ubuntu web server, a Red Hat database node, or an embedded Raspberry Pi, you can always expect to find system configuration in `/etc`, temporary files in `/tmp`, and variable application data in `/var`.

But as a system administrator, your map is not just a guide for navigation; it is a live ledger of physical block space. When a monitoring alert warns that a disk is 95% full, you cannot rely on simple visual maps. You need to weigh the contents of the files, identify space-hogging directories, and isolate real, physical storage from ghostly virtual placeholders and shortcuts. 

In this chapter, we will learn how to accurately audit filesystem capacity, how the kernel maps symbolic shortcuts, and how to avoid the common math traps that virtual directories play on unsuspecting administrators.

---

## The Warehouse and the Hologram

Imagine you are hired as a capacity auditor for a massive warehouse. Your job is to generate a report showing the physical weight of the inventory stored in each room of the building.

Most rooms are straightforward: they contain wooden crates and steel pallets. You can roll your scale in, weigh the crates, and log the results. 

But as you explore the warehouse, you run into three unique rooms:

1.  **The Projection Room (`/proc` and `/sys`)**: This room is completely empty of physical objects. Instead, it is filled with real-time holographic projections displaying the factory's current engine RPM, temperature, and employee count. If you try to weigh these holograms, your physical scales will register zero, or worse, get completely confused.
2.  **The Connected Bridge (`/mnt/external`)**: This room has a door leading to a separate, independent storage warehouse next door. If you cross the bridge and weigh that inventory, you will accidentally include another building's data in your local report.
3.  **The Teleporter Pad (`/bin` or `/lib`)**: This is a small portal pad. If you step onto it, you are instantly teleported to a deep cellar located underneath the building (`/usr/bin` or `/usr/lib`). It is not a real room; it is just a shortcut.

In Linux, directories like `/proc` and `/sys` are the holographic projection rooms. Separate mount points are the connected bridges, and symbolic links are the teleporter pads. To audit your local disk space accurately, you must know how to isolate your scales so they only weigh the local, physical cargo.

---

## Part I: Weighing the Cargo with `du`

The default tool for measuring directory sizes is `du` (Disk Usage). 

If you run `du` by itself without any arguments, it will print a line for every single nested subdirectory on your system, scrolling past your eyes in an overwhelming blur of numbers. To make this tool practical, we must restrict its depth and format its output.

### Restricting the View
To limit our capacity audit to only the top-level folders, we use the depth constraint:

```bash
sudo du -d 1 /
# OR
sudo du --max-depth=1 /
```

This instructs `du` to calculate the sizes of all files and folders under `/`, but only output the final sum for directories directly under the root level (such as `/home`, `/var`, `/usr`).

### Making the Numbers Readable
By default, `du` displays sizes in raw block counts, which are difficult for humans to read. Adding the `-h` (human-readable) flag formats the sizes into kilobytes, megabytes, and gigabytes:

```bash
sudo du -h -d 1 /
```

Now, instead of seeing `4194304`, you see `4.0G`.

---

## Part II: Isolating the Scales

If you run `sudo du -hd 1 /` on a live production server, you will likely see a cascade of permission errors, your terminal might freeze, or the calculated size of your drive will be wildly incorrect. 

This happens because, by default, `du` is naive. It will happily walk across the connected bridges into separate hard drives and try to weigh the ghostly holograms of the virtual directories.

We must configure our scales to stay on the local root drive and ignore the non-physical zones.

### Staying on One Filesystem with `-x`
The `-x` (or `--one-file-system`) option is the most important flag in directory sizing. It tells `du` to immediately skip any directory that resides on a separate physical or remote partition. 

If you have a 10TB NFS network storage share mounted at `/mnt/archive`, running `du -x /` will calculate `/mnt/archive` as `0` bytes of local space because it recognizes that the storage resides on a separate server over the network. It forces the tool to stay strictly on the disk backing `/`:

```bash
sudo du -xh -d 1 /
```

### Excluding the Virtual Zones
Even with `-x`, virtual pseudo-filesystems (like `/proc` and `/sys`) can confuse measurement queries because they exist in memory rather than on disk. To keep our reports pristine, we can explicitly exclude these directories using the `--exclude` pattern:

```bash
sudo du -h -d 1 --exclude="/proc" --exclude="/sys" --exclude="/dev" /
```

By applying these exclusions, you guarantee that your capacity report represents real, physical sectors written to local oxide.

---

## Part III: Organizing the Inventory

Once you have a list of directory sizes, they will be printed in standard directory order, which makes finding the largest files difficult. To locate the storage consumers, we must pipe our output to the `sort` command.

Traditional sorting (`sort -n`) only understands raw numbers. If you try to sort human-readable sizes (like `120M` and `2G`), a standard numerical sort will put `120M` above `2G` because `120` is larger than `2`.

To solve this, we use the `-h` (human-numeric sort) option inside the `sort` utility. This flag tells `sort` to understand storage suffixes, recognizing that `2G` is larger than `120M`:

```bash
sudo du -xh -d 1 / | sort -h
```

To reverse the list so that the largest directories appear at the very bottom (or top) of your screen for immediate viewing, add the `-r` (reverse) flag:

```bash
sudo du -xh -d 1 / | sort -hr
```

---

## Part IV: Auditing the Shortcuts

In Linux, filesystems can contain pointers called **Symbolic Links** (or symlinks). They are small files containing a text string that points to another target directory or file.

If you navigate into a symlink, your shell silently teleports you to the target path. While this is convenient, it presents a challenge for capacity audits. If you have a symlink at `/bin` pointing to `/usr/bin`, does `/bin` actually consume space? No, it is just a text pointer.

To find all symbolic links directly under the root level of your filesystem, we use the `find` utility restricted to a single level depth:

```bash
find / -maxdepth 1 -type l
```

*   `/`: The path to start searching.
*   `-maxdepth 1`: Limits the search strictly to the top-level directory, preventing `find` from walking down into subdirectories.
*   `-type l`: Tells `find` to output only files that are symbolic links.

To find out exactly where a specific symlink points, you can use the long-list directory format or the direct `readlink` utility:

```bash
ls -ld /bin
# OR
readlink /bin
```

The output of `ls -ld` will display an `l` as the very first character of the permission block, and show the target path with an arrow:

```text
lrwxrwxrwx 1 root root 7 Aug 24 2026 /bin -> usr/bin
```

---

## Self-Check and Verification

Test your capacity auditing skills before conducting reports on live servers:
1.  **The Over-Counting Trap**: You run `du -sh /` and get a size of 45GB. But when you run `df -h`, it shows only 20GB of space used on your physical drive `/dev/vda1`. Why does `du` report more space than `df`? *(Answer: Naive `du` walked across your mount points into other mounted drives and network shares, summing their remote capacities into your root count. Always use `-x` to restrict your measurement scales to a single drive).*
2.  **Tracking Symlink Targets**: If `/sbin` is a symbolic link pointing to `usr/sbin`, where are the physical binary files actually located? *(Answer: They are located on disk inside `/usr/sbin`. The path `/sbin` is merely a shortcut).*
3.  **Human Sorting**: Why does running `sort -n` on human-readable storage sizes fail? *(Answer: Standard numerical sort treats units as text; it does not know that 'G' represents a multiplier of 1024 times 'M'. You must use `sort -h` to make the sorting engine aware of unit suffixes).*
