# Solution

## Step 1: Identify the raw disks before touching anything

```bash
lsblk
```

Look for a disk in the output with no `FSTYPE` and no `MOUNTPOINT` — that confirms it's a raw, unformatted disk and not, say, a disk that already has data or is already mounted somewhere unexpected. **Don't assume a specific device letter** (`/dev/vdb`, `/dev/vdc`, ...) — on some runtimes extra disks don't attach in a fixed, predictable order relative to the VM's own root disk, so the blank disk could show up as any letter. Identifying it by its empty `FSTYPE`/`MOUNTPOINT` columns rather than a hardcoded name is what separates "confident sysadmin" from "person who just wiped the wrong disk." Capture it into a variable so the rest of the steps don't have to re-derive it:

```bash
BLANK=$(lsblk -rno NAME,FSTYPE,MOUNTPOINT | awk '$2=="" && $3==""{print "/dev/"$1; exit}')
echo "$BLANK"
```

Cross-check with:

```bash
sudo blkid "$BLANK"
```

`blkid` with no output for a device means it has no recognized filesystem signature yet — exactly what you expect for a fresh disk.

## Step 2: Format the disk with ext4

```bash
sudo mkfs.ext4 "$BLANK"
```

`mkfs.ext4` writes an ext4 superblock, inode tables, and block group metadata directly onto the device. This is destructive and irreversible for anything previously on that device, which is exactly why Step 1 happened first — and exactly why guessing a device letter instead of verifying it is dangerous. Note we format the whole device (`$BLANK`), not a partition (`${BLANK}1`) — in this scenario no partition table was requested, so we treat the raw device as the filesystem target, which is common for virtual/cloud-attached disks.

## Step 3: Create the mountpoint and mount it

```bash
sudo mkdir -p /mnt/backup-black
sudo mount "$BLANK" /mnt/backup-black
```

`mount` attaches the filesystem on `$BLANK` into the directory tree at `/mnt/backup-black`. The mountpoint directory must already exist — `mount` will not create it for you. `mkdir -p` is safe even if part of the path already exists.

## Step 4: Create the marker file

```bash
sudo touch /mnt/backup-black/completed
```

Writing to `/mnt/backup-black` now writes into the ext4 filesystem on `$BLANK`, not the root filesystem — confirm this makes sense conceptually: the directory is now a mount boundary.

## Step 5: Compare usage between the two already-mounted disks

```bash
df -h
```

Scan the output for the two other extra disks — they'll show up mounted somewhere under `/mnt` (alongside `$BLANK`, now mounted at `/mnt/backup-black`). Example output:

```
Filesystem      Size  Used Avail Use% Mounted on
/dev/vdb        3.0G  2.1G  700M  75% /mnt/backup-blue
/dev/vdc        3.0G  980M  1.9G  33% /mnt/backup-red
```

(Your actual device letters may differ — go by the `/mnt/backup-*` mountpoints, not the `/dev/vdX` column.) Here the disk mounted at `/mnt/backup-blue` has both higher `Used` and higher `Use%` — that's the disk with higher storage usage. If the two disks are different sizes, always compare the `Used` column (absolute bytes consumed) rather than `Use%`, since "usage" in the task means actual space occupied, not how full the disk is relative to its own capacity. Cross-check with `lsblk` if `df` output is ambiguous about which device maps to which line:

```bash
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT
```

## Step 6: Empty the .trash folder on the busier disk

Assuming `/mnt/backup-blue` won:

```bash
sudo rm -rf /mnt/backup-blue/.trash/*
```

Note the trailing `/*` — this empties the contents of `.trash` while leaving the `.trash` directory itself in place, matching "empty the folder" rather than "delete the folder." If `.trash` might contain dotfiles too, use:

```bash
sudo find /mnt/backup-blue/.trash -mindepth 1 -delete
```

`find -mindepth 1 -delete` catches hidden files that a bare glob (`*`) would skip, and is generally the safer, more complete way to empty a directory.

## Step 7: Compare memory usage of the two processes

Check `man 1 ps` — the `STANDARD FORMAT SPECIFIERS` section lists `vsz` and `rss` as valid `-o` fields, and documents `--sort` with a leading `-` for descending order.

```bash
ps -eo pid,ppid,vsz,rss,comm | grep -E 'dark-matter-v1|dark-matter-v2'
```

or sorted directly:

```bash
ps -eo pid,vsz,rss,comm --sort=-rss | grep dark-matter
```

`VSZ` (virtual memory size, KB) and `RSS` (resident set size, KB) are both shown so you can judge on either metric as the task allows. Whichever of `dark-matter-v1` / `dark-matter-v2` has the larger number in the relevant column is the one you act on next. Record its PID.

## Step 8: Find the executable path of the winning process

Check `man 5 proc` — search for `/proc/[pid]/exe` to confirm it's a magic symlink, not a regular file, and note the page's warning about reading it via `readlink` rather than opening it directly.

```bash
sudo readlink -f /proc/<PID>/exe
```

`/proc/<PID>/exe` is a magic symlink maintained live by the kernel that always points at the file currently backing that process's executable mapping. `readlink -f` resolves it fully, including through any intermediate symlinks, and prints a clean absolute path like `/mnt/backup-red/bin/dark-matter-v2`. Do not `cat` or execute this symlink — only read its target.

## Step 9: Map that path to its mounted device

```bash
df /mnt/backup-red/bin/dark-matter-v2
```

or, more precisely for confirming the exact device and options:

```bash
findmnt -T /mnt/backup-red/bin/dark-matter-v2
```

`findmnt -T <path>` (Target) walks up the path until it finds the mount covering it, and reports the source device, filesystem type and mount options — this is the authoritative way to answer "what device is this file actually on," especially useful if mounts are nested several directories deep.

## Step 10: Unmount that disk

```bash
sudo umount /mnt/backup-red
```

Check `man 8 umount` — the section discussing `-l`/`--lazy` explains what a lazy unmount actually defers, which is worth reading before reaching for it as a shortcut.

If this fails with `target is busy`, something still has an open handle on it — most likely your own shell's `cwd`, or the process itself if it's still running from that path. Confirm with:

```bash
sudo lsof +D /mnt/backup-red
sudo fuser -vm /mnt/backup-red
```

then `cd ~` out of the mount, kill/close whatever is holding it if appropriate, and retry `umount`.

## Verification

```bash
# blank disk formatted, mounted, marker file present
mount | grep backup-black
ls -l /mnt/backup-black/completed

# confirm which backup disk was busier and its .trash is empty
df -h
ls -la /mnt/backup-blue/.trash    # (or backup-red, whichever won) -> should show no entries besides . and ..

# confirm the higher-memory process's disk is unmounted
mount | grep backup-red           # should print nothing if that was the target
```

Expected: `/mnt/backup-black` shows up in `mount` output, `completed` exists as an empty file, the winning `.trash` directory is empty, and the disk hosting the winning process's executable no longer appears in `mount`.

## Command Summary

```bash
lsblk
BLANK=$(lsblk -rno NAME,FSTYPE,MOUNTPOINT | awk '$2=="" && $3==""{print "/dev/"$1; exit}')
sudo blkid "$BLANK"
sudo mkfs.ext4 "$BLANK"
sudo mkdir -p /mnt/backup-black
sudo mount "$BLANK" /mnt/backup-black
sudo touch /mnt/backup-black/completed
df -h
sudo find /mnt/backup-blue/.trash -mindepth 1 -delete
ps -eo pid,vsz,rss,comm --sort=-rss | grep dark-matter
sudo readlink -f /proc/<PID>/exe
findmnt -T /mnt/backup-red/bin/dark-matter-v2
sudo umount /mnt/backup-red
```
