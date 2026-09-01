# Solution Guide: Navigating Shortcuts: Symbolic Links

This guide shows you how to locate and resolve symbolic link structures.

---

## Step 1: Locate all Symbolic Links

Use the `find` tool to locate links under the target directory:
```bash
find /usr/share/lab-links -type l
```

---

## Step 2: Resolve target paths

Run `readlink` on the links to inspect where they point:
```bash
readlink /usr/share/lab-links/link1
readlink /usr/share/lab-links/link2
readlink /usr/share/lab-links/link3
readlink /usr/share/lab-links/link4
```
Observe which link targets contain `/etc/alternative` or `/opt/target`.
- `link1` -> `/etc/alternative/editor` (Match)
- `link2` -> `/var/log` (No match)
- `link3` -> `/opt/target/system` (Match)
- `link4` -> `/etc/hosts` (No match)

---

## Step 3: Save results

Write the matching symlink paths (sorted alphabetically) to `/opt/course/audit/symlink_report.txt`:
```bash
sudo mkdir -p /opt/course/audit
sudo nano /opt/course/audit/symlink_report.txt
```
Populate with:
```text
/usr/share/lab-links/link1
/usr/share/lab-links/link3
```
