# Question

Solve this question on: `terminal`

Configure a temporary memory expansion by allocating and enabling a secure swap file.

1. Allocate a 512MB swap file at `/swapfile` (use a secure allocation tool like `dd` or `fallocate`).
2. Secure the file permissions so that only the `root` user can read and write to it.
3. Format `/swapfile` as a swap space.
4. Enable the swap file so that the system immediately gains virtual memory.
5. Add an entry to `/etc/fstab` to make `/swapfile` persistent across reboots.
