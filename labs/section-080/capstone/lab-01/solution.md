# Solution Guide (Offline & Exam Friendly)

This step-by-step guide walks you through generating a physical disk capacity report and identifying symlinks under `/` without needing to memorize complex scripts or command-line parsers.

---

## Step 1: Create the Report Directory

Create the target directory where the reports will be saved:

```bash
sudo mkdir -p /opt/course/audit
```

---

## Step 2: Survey Top-Level Directory Sizes

You need to find the size of top-level directories on the root filesystem `/`.

1. If you forget how to use `du` to inspect directory sizes, run:
   ```bash
   du --help
   ```
   *Identify options for:*
   - Human-readable sizing (`-h` or `--human-readable`).
   - Restricting recursion depth to the top-level folders only (`--max-depth=1`).
   - Keeping the scan within a single filesystem (`-x` or `--one-file-system`). This is critical to prevent the tool from traversing separate disks or network shares.
2. Run the command and sort the results by size, largest first:
   ```bash
   sudo du --max-depth=1 -h -x / 2>/dev/null | sort -rh
   ```
   *`sort -rh` sorts lines using human-readable suffix magnitudes (like K, M, G).*

---

## Step 3: Identify Virtual (Memory-Only) Filesystems

The capacity report must reflect real, disk-backed usage. Filesystems that only exist in memory (like `proc`, `sysfs`, `tmpfs`) must be excluded.

1. List the virtual mounts on your system:
   ```bash
   findmnt -t proc,sysfs,tmpfs,devtmpfs
   ```
2. Cross-reference this output with your `du` list from Step 2. You will see that `/proc`, `/sys`, `/dev`, and `/run` are virtual filesystems, so they should be excluded from your final capacity report.

---

## Step 4: Identify Symlinked Directories under `/`

You need to find which top-level paths are symbolic links and what they point to.

1. Run a detailed file list of the root directory:
   ```bash
   ls -l /
   ```
2. Look at the output. Rows representing symbolic links start with the character **l** in their permissions column, and end with an arrow `->` showing where they point:
   ```text
   lrwxrwxrwx  1 root root    7 Aug 24 12:00 bin -> usr/bin
   lrwxrwxrwx  1 root root    7 Aug 24 12:00 lib -> usr/lib
   lrwxrwxrwx  1 root root    9 Aug 24 12:00 lib64 -> usr/lib64
   lrwxrwxrwx  1 root root    8 Aug 24 12:00 sbin -> usr/sbin
   ```
3. Record these symlinks manually into the `/opt/course/audit/symlinks.txt` file by opening it in your editor, or write them directly using `tee`:
   ```bash
   sudo tee /opt/course/audit/symlinks.txt <<'EOF'
   bin -> usr/bin
   lib -> usr/lib
   lib64 -> usr/lib64
   sbin -> usr/sbin
   EOF
   ```
   *Note: If your system has different symlinks, write those down exactly as shown in your `ls -l /` output.*

---

## Step 5: Filter the Virtual Filesystems and Symlinks to Write the Capacity Report

1. Re-run `du` and use `grep -Ev` to filter out virtual filesystems (`proc`, `sys`, `dev`, `run`) as well as the symlinked directories we recorded in Step 4, then sort the results:
   ```bash
   sudo du --max-depth=1 -h -x / 2>/dev/null \
     | grep -Ev '/(proc|sys|dev|run|bin|sbin|lib|lib64)$' \
     | sort -rh \
     | sudo tee /opt/course/audit/dirsizes.txt
   ```
2. View the generated file to ensure it looks correct and contains only real, disk-backed, top-level directories:
   ```bash
   cat /opt/course/audit/dirsizes.txt
   ```

---

## Verification

Verify both outputs to ensure they meet the criteria:

```bash
# 1. Confirm symlink report matches
cat /opt/course/audit/symlinks.txt

# 2. Confirm capacity report is sorted and has no virtual directories
cat /opt/course/audit/dirsizes.txt

# 3. Crosscheck total disk usage on /
df -h /
```
