# Question

Solve this question on: `terminal`

One of the attached devices is experiencing severe write performance problems due to heavy background traffic.

1. Run standard device analytics (e.g. `iostat -xz 1`) to watch active disk stats.
2. Identify which disk device (e.g. `vdb` or `vdc` or `vdd`) has a higher average wait time (`await`) or higher percentage utilization (`%util`).
3. Write the short name of this saturated device (for example, `vdb` or `vdc` as shown in `lsblk`) to `/opt/course/audit/slow_device.txt`.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-01](../../course.md).

The grader checks:

- Confirms proper identifying of the slow saturated disk device.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
