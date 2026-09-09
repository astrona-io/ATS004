# Question

Solve this question on: `terminal`

The `/quota` filesystem is already mounted with `usrquota,grpquota` options, but quota enforcement is not active yet. Users `alice` and `bob`, and group `team` (containing both), already exist.

1. Build the quota accounting files and turn on user and group quota enforcement for `/quota`.
2. Set a block quota for `alice`: 40M soft, 50M hard (no inode limit).
3. Set a block quota for `bob`: 20M soft, 30M hard (no inode limit).
4. Set a block quota for group `team`: 100M soft, 120M hard (no inode limit).
5. Confirm the limits with `repquota -s /quota`.
