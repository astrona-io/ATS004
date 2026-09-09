# User and Group Disk Quotas

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-080/module-02/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-080/module-02/playground
> astrona destroy section-080-module-02-playground
> ```

On a shared system, one user filling a filesystem stops everyone. **Disk quotas** cap how much space (and how many files) each user or group may consume on a given filesystem, so one account cannot starve the rest.

## How this module is organised

1. **[Part 1 — Turning Quotas On & Setting Limits](./course-01-turning-on-and-setting-limits.md)** — the three things that must line up before enforcement works, where the kernel actually checks a quota, and setting per-user/per-group soft and hard limits.
2. **[Part 2 — Hitting the Limit & the Grace Period](./course-02-hitting-the-limit-and-grace-period.md)** — what happens when a write crosses hard, the grace-period countdown that governs soft, and a consolidated pitfall list.

## Learning objectives

After this module you can:

- Enable quotas on an ext4 filesystem with the right mount options, `quotacheck`, and `quotaon`.
- Explain where the kernel actually enforces a quota — at write-syscall time against an in-kernel structure — and why `quotacheck` must run before the first `quotaon`.
- Set per-user and per-group block and inode limits with `setquota` (and `edquota`).
- Explain the difference between a soft limit, a hard limit, and the grace period, and trace the state transitions between under-soft, over-soft, and blocked.
- Read quota usage with `repquota` and `quota`.

## Before you start

You need Section 015 (fstab mount options) and to be comfortable with users, groups, and `sudo`.

The linked playground gives you an Ubuntu server VM with a 2 GB ext4 filesystem mounted at `/quota` (its `/etc/fstab` line already carries `usrquota,grpquota`, but quotas are **not on yet**), test users **alice** and **bob**, group **team**, and the `quota` toolset installed. Run the command blocks in Parts 1–2 in that VM after `astrona ssh section-080-module-02-playground`.
