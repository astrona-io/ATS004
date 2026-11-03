# Question

Solve this question on: `terminal`

Astronaut, a cargo hold on your training ship will not undock. A disk is already formatted and mounted at `/mnt/locked-vault`, and a background process is still inside it, so the kernel refuses to unmount it. Find the crew member who is holding it, send them out, and undock the hold, without disturbing the rest of the crew.

1. Try to unmount `/mnt/locked-vault`, and confirm that the kernel refuses because the target is busy.
2. Use `lsof` and/or `fuser` to identify exactly which process is holding the mount open.
3. Stop that process cleanly: try a graceful stop first, and only force it if it does not exit on its own. The process must stay stopped. Do not stop any other running service or process on the system (for example `sshd`).
4. Unmount `/mnt/locked-vault` successfully once the process is gone. Leave it unmounted.

The grader checks the live machine: the holding process is no longer running, nothing is mounted at `/mnt/locked-vault`, and the rest of the system (such as `sshd`) is still running.
