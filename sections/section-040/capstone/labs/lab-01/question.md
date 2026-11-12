# Question

Solve this question on: `terminal` (playing the role of `data-001` from the scenario)

Server `data-001` has started OOM-killing background jobs under load, and `free -h` confirms there is currently **no swap configured at all**. There is no spare unpartitioned disk space for a new partition right now, so the immediate fix is a 2G swap file. Once that's live, a colleague frees up a dedicated partition intended for swap — it's the disk with exactly one partition that has no filesystem type yet (use `lsblk` to find it, don't assume a specific `/dev/vdX` name) — that should become the *primary* swap area, with the swap file demoted to a fallback that the kernel only uses once the partition fills up.

Create a 2G swap file, secure its permissions, activate it, and make it persistent via `/etc/fstab`. Then size and activate that swap partition, and configure priorities so the partition (`pri=10`) is preferred over the swap file (`pri=5`) — higher priority is used first.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-01](../../../module-01/course.md), [module-02](../../../module-02/course.md).

The grader checks:

- Confirms a ~2G file-type swap area is active.
- Confirms the active swap file's mode is 600.
- Confirms the swap file is persisted in /etc/fstab with type swap.
- Confirms the swap file's active priority is 5.
- Confirms the extra disk's first partition (resolved by serial, not a guessed letter) is active as partition-type swap.
- Confirms that partition's active priority is 10, preferred over the swap file's 5.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
