# Question

Solve this question on: `terminal` (playing the role of `data-001` from the scenario)

A migration is planned for `data-001` and you're asked to produce a capacity report before it happens. Write a sorted, human-readable size report of every top-level directory under `/` into `/opt/course/audit/dirsizes.txt`, largest first. The report must reflect real, disk-backed usage only — it must not include pseudo-filesystem directories that only exist in memory while the system is running, and it must not follow into any separately mounted filesystem (so a large NFS mount under `/mnt` doesn't get folded into `/`'s number). Separately, identify any top-level directory that is actually a symlink rather than a real directory, and note what each one points to in `/opt/course/audit/symlinks.txt`.
