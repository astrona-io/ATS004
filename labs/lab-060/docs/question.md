# Question

Solve this question on: `terminal`

A colleague is debugging a service on `terminal` and asks you to gather some live kernel-state facts and make one temporary tuning change, all without touching any GUI tool or restarting anything:

Report total and available memory directly from the kernel's own memory accounting.

Given a running process's PID, report how many file descriptors it currently has open.

Temporarily enable IPv4 IP forwarding for the current boot only (not persisted), then show the exact `sysctl`-equivalent variable name for what you just changed.

Show the filesystem type and mount options for `/` by reading the kernel's live mount table directly, and explain how that differs from asking `mount` or `findmnt`.

A target process's PID is available at `/opt/course/target.pid` for the file-descriptor-count part of the task.
