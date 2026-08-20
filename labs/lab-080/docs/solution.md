# Solution

## Step 1: Set up the report location

```bash
sudo mkdir -p /opt/course/audit
```

## Step 2: Get a first-pass size for every top-level directory

```bash
sudo du --max-depth=1 -h -x / 2>/dev/null | sort -rh
```

Check `man 1 du` — `--max-depth=1` limits recursion to exactly one level below the starting point (`/`), which is what gives you one line per top-level directory instead of every file on the system. `-x` (check the man page's description of "one file system") is the flag that keeps the scan from wandering into anything mounted underneath `/` — without it, a large network share or a second disk mounted at `/data` would inflate `/`'s reported total with space that isn't actually part of the root filesystem. Redirecting stderr to `/dev/null` suppresses "Permission denied" noise from directories you can't read even as root's scan encounters restrictive mount options.

`sort -rh` — check `man 1 sort`'s `-h` flag description — reorders the output largest-first by treating suffixes like `K`/`M`/`G` as actual magnitude, not as plain text.

## Step 3: Confirm which top-level entries are pseudo-filesystems

```bash
findmnt -t proc,sysfs,tmpfs,devtmpfs
```

Cross-reference this list against your Step 2 output — any top-level directory that appears here (typically `/proc`, `/sys`, `/dev`, `/run`, sometimes `/tmp` if it's tmpfs-backed on this distro) is not real root-filesystem disk usage, regardless of what `du` reported for it. Exclude those lines from the report.

## Step 4: Identify symlinked top-level directories

```bash
ls -l / | grep '^l'
```

Check `man 1 ls` — the leading `l` in the permissions column identifies a symlink; the rest of the line shows what it points to (e.g. `bin -> usr/bin`). On most current distributions, `/bin`, `/sbin`, `/lib`, and `/lib64` are symlinks into their `/usr` counterparts (the "usr-merge"). Each symlinked entry you find here should be excluded from your size total for `/` — it isn't separate data, it's the same bytes `/usr` already accounts for.

## Step 5: Build the final filtered report

```bash
sudo du --max-depth=1 -h -x / 2>/dev/null \
  | grep -Ev '/(proc|sys|dev|run)$' \
  | sort -rh \
  | sudo tee /opt/course/audit/dirsizes.txt
```

The `grep -Ev` step drops the pseudo-filesystem lines identified in Step 3 before sorting and writing the report. Because `-x` already prevented `du` from crossing into other real mounted filesystems, and the pseudo-filesystems are filtered here, what remains is disk-backed usage on the root filesystem only.

## Step 6: Record the symlinks separately

```bash
ls -l / | grep '^l' | awk '{print $9, $10, $11}' | sudo tee /opt/course/audit/symlinks.txt
```

`awk '{print $9, $10, $11}'` pulls just the name, the arrow, and the target from each symlink line — check `man 1 ls`'s output format description to confirm which columns those are on your system, since exact column count can shift slightly by distro/locale.

## Verification

```bash
cat /opt/course/audit/dirsizes.txt
# expect: one line per real, disk-backed top-level directory, largest first,
# no /proc, /sys, /dev, or /run entries

cat /opt/course/audit/symlinks.txt
# expect: one line per top-level symlink (typically bin, sbin, lib, lib64),
# each showing its target

df -h /
# cross-check: the sum of dirsizes.txt entries should be in the right ballpark
# for the "used" figure this reports for the root filesystem
```

## Command Summary

```bash
sudo mkdir -p /opt/course/audit

sudo du --max-depth=1 -h -x / 2>/dev/null | sort -rh

findmnt -t proc,sysfs,tmpfs,devtmpfs

ls -l / | grep '^l'

sudo du --max-depth=1 -h -x / 2>/dev/null \
  | grep -Ev '/(proc|sys|dev|run)$' \
  | sort -rh \
  | sudo tee /opt/course/audit/dirsizes.txt

ls -l / | grep '^l' | awk '{print $9, $10, $11}' | sudo tee /opt/course/audit/symlinks.txt

cat /opt/course/audit/dirsizes.txt
cat /opt/course/audit/symlinks.txt
df -h /
```
