# Question

Solve this question on: `terminal`

The XFS filesystem `/srv/xfs` is already mounted with `uquota,pquota` — quota accounting and enforcement are active, but no limits are set yet.

1. Give user `alice` a block quota of `40m` soft / `50m` hard on `/srv/xfs`.
2. Define a project named `webdata` with ID `42` for the directory `/srv/xfs/webdata` (register it in `/etc/projects` and `/etc/projid`, then initialise it).
3. Give the `webdata` project a block quota of `100m` hard.
4. Confirm both limits are active by reporting on user and project quotas.
