# Question

Solve this question on: `terminal`

Audit symbolic link targets across the system files.

1. Locate all symbolic links under `/usr/share/lab-links`.
2. Inspect their target paths (using `readlink` or `file`).
3. Identify which of those links point specifically to a path containing the string `/etc/alternative` or `/opt/target`.
4. Document the absolute paths of these matching symbolic links inside `/opt/course/audit/symlink_report.txt`, sorted alphabetically.
