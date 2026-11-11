# Question

Solve this question on: `terminal` (playing the role of `data-001` from the scenario)

A migration is planned for `data-001` and you're asked to produce a capacity report before it happens. Write a sorted, human-readable size report of every top-level directory under `/` into `/opt/course/audit/dirsizes.txt`, largest first. The report must reflect real, disk-backed usage only — it must not include pseudo-filesystem directories that only exist in memory while the system is running, and it must not follow into any separately mounted filesystem (so a large NFS mount under `/mnt` doesn't get folded into `/`'s number). Separately, identify any top-level directory that is actually a symlink rather than a real directory, and note what each one points to in `/opt/course/audit/symlinks.txt`.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-01](../../../module-01/course.md), [module-02](../../../module-02/course.md), [module-03](../../../module-03/course.md), [module-04](../../../module-04/course.md).

The grader checks:

- Confirms /opt/course/audit/dirsizes.txt exists and is non-empty.
- Confirms dirsizes.txt entries are sorted largest first.
- Confirms dirsizes.txt contains no /proc, /sys, /dev, or /run entries.
- Confirms the /mnt entry (if present) is small, proving du -x kept the scan from crossing into the bigshare mount.
- Confirms /opt/course/audit/symlinks.txt exists, is non-empty, and every listed path is a real symlink.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
