# Directory Capacity Auditing

When a monitoring alert fires at 2 AM stating that `/` (the root filesystem) is 100% full, the `df -h` command only confirms the disaster. It tells you the disk is full, but it cannot tell you *what* filled it up.

To find the massive log file or rogue database backup suffocating your server, you have to measure the directories from the top down. Think of this as rolling physical cargo scales into every room of a warehouse to find the heaviest pallet.

You measure directory consumption using `du` (Disk Usage).

## Navigating the Noise

Running `du` by itself at the root of a server is useless. It prints the size of every single file on the system, in kilobytes, creating an endless, unreadable wall of text.

You format the output for humans and limit the depth to one level down using `-h` and `-d 1`.

```bash
du -h -d 1 /var
```

This commands `du` to weigh everything inside `/var`, but only print the total summary for each top-level folder (like `/var/log`, `/var/lib`). It rolls up the numbers instead of listing every file.

To quickly find the largest directories, you pipe this output into `sort`. The `-h` flag tells `sort` to respect the human-readable formats (K, M, G), and the `-r` flag reverses the output so the largest folders sit at the top of your screen.

```bash
du -h -d 1 /var | sort -hr
```

## The Catastrophe of Mount Boundaries

When you run `du` against the root directory (`/`), you trigger a hidden landmine.

A Linux server is not one giant disk. It is a mosaic of different filesystems mounted into a single tree. You might have `/` on a 20GB local disk, `/mnt/nfs` mounted to a 50-Terabyte network share, and `/proc` mounted to the live kernel memory.

If you run `du -h -d 1 /`, `du` blindly follows every path. It will attempt to weigh the 50-Terabyte network share over the wire, taking hours. Worse, it will attempt to weigh the virtual files inside `/proc` and `/sys`, which can cause kernel locks or false readings since they are not real files.

To find out what is filling up the physical 20GB root disk, you must restrict `du` to that exact filesystem boundary. You use the `-x` (one-file-system) flag.

```bash
du -hx -d 1 / | sort -hr
```

The `-x` flag tells `du` to stop the moment it hits a directory that is mounted to a different device. When it hits `/mnt/nfs`, it ignores it. When it hits `/proc`, it ignores it. It only weighs the data physically resting on the root disk. This is the only safe, accurate way to audit a full partition.

## Self-Check and Verification

To prove you can safely audit disk consumption:

1. Use `df -h` to identify the mount point of your primary system partition.
2. Run a standard `du -h -d 1 /var` and note the output.
3. Pipe the output into `sort -hr` to identify the largest top-level directory in `/var`.
4. Run `du -hx -d 1 / | sort -hr` against the root of the filesystem.
5. Verify that network mounts, `/proc`, and `/dev` are ignored and register essentially zero bytes in the sorted output, proving the `-x` boundary hold firm.
