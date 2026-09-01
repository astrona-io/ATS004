# Solution Guide: Directory Capacity Profiling

Learn how to audit storage boundaries safely using the disk usage utility.

---

## Step 1: Query Folder Sizes Safely

Run the `du` tool with parameters to:
- Restrict to the local filesystem (`-x`)
- Output in human-readable units (`-h`)
- Set maximum subdirectory recursion depth to 1 (`-d 1` or `--max-depth=1`)

```bash
sudo du -xhd 1 /var/log | sort -h
```

---

## Step 2: Observe and Isolate the Result

Look at the output lines.
- `/var/log/external_backup` is mounted on a separate disk. With `-x` active, its listed capacity is close to `0` or minimal metadata.
- `/var/log/heavy_local_log` is a local directory and should show high capacity (around 200MB).

Without `-x`, `/var/log/external_backup` would show as the largest. Because of the local boundary restriction, `/var/log/heavy_local_log` is the correct answer.

---

## Step 3: Write the Report

Save the largest directory name to `/opt/course/audit/heavy_dirs.txt`:
```bash
sudo mkdir -p /opt/course/audit
echo "/var/log/heavy_local_log" | sudo tee /opt/course/audit/heavy_dirs.txt
```
