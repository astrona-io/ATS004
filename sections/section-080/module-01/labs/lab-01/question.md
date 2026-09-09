# Question

Solve this question on: `terminal`

Audit capacity inside the `/var/log` directory structure.

The administration wants to locate the largest local subdirectory under `/var/log`.

1. Profile immediate subdirectories at `/var/log` (depth of 1 only).
2. Ensure you stay strictly on the local root filesystem device (`-x` or `--one-file-system`). Do not count space on separate, nested physical or virtual drives mounted under `/var/log`.
3. Locate the largest subdirectory matching these parameters and write its absolute folder path to `/opt/course/audit/heavy_dirs.txt`.
