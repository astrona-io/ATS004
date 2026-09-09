# Question

Solve this question on: `terminal`

One of the attached devices is experiencing severe write performance problems due to heavy background traffic.

1. Run standard device analytics (e.g. `iostat -xz 1`) to watch active disk stats.
2. Identify which disk device (e.g. `vdb` or `vdc` or `vdd`) has a higher average wait time (`await`) or higher percentage utilization (`%util`).
3. Write the short name of this saturated device (for example, `vdb` or `vdc` as shown in `lsblk`) to `/opt/course/audit/slow_device.txt`.
