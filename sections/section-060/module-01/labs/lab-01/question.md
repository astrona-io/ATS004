# Question

Solve this question on: `terminal`

Investigate system resource consumption using the `/proc` virtual filesystem.

1. Identify the running process ID of `systemd-journald`.
2. Count the active open file descriptors for this process PID using `/proc/<PID>/fd/` and write this count as a single integer to `/opt/course/audit/fd_count.txt`.
3. Locate the maximum system-wide open file limit defined by the kernel. Write this value to `/opt/course/audit/file_max.txt`.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-01](../../course.md).

The grader checks:

- Confirms proper extraction of proc open file descriptors and system-wide limit.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
