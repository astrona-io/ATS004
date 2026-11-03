# Question

Solve this question on: `terminal`

Astronaut, two cargo holds on this ship have allowances to set up.

- The ext4 filesystem `/quota-ext` has user quotas switched on. The user `alice` already has the limits that mission control likes: **40M soft and 50M hard** for blocks. The users `bob` and `carol` have no limits yet.
- The XFS filesystem `/srv/xfs-teams` is mounted with group quotas (`gquota`). The group `engineers` has no limits yet.

1. Copy `alice`'s quota limits to `bob` and `carol` on `/quota-ext` with one `edquota` command. Do not type the numbers again.
2. Give the group `engineers` a block quota of `50m` soft and `80m` hard on `/srv/xfs-teams`, using `xfs_quota`.
3. Set the block grace timer for groups on `/srv/xfs-teams` to `3days`.
4. Confirm everything with `repquota -s /quota-ext`, `xfs_quota -x -c 'report -g -h' /srv/xfs-teams` and `xfs_quota -x -c 'state -g' /srv/xfs-teams`.

The grader reads the live quota tables on both filesystems.
