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

## The parts of this module

1. [Turning Quotas On & Setting Limits](./course-01-turning-on-and-setting-limits.md): the three things that must line up, where the kernel checks a quota, and the first user limits.
2. [Group Quotas, Copying Limits & Reading Reports](./course-02-group-quotas-and-reports.md): group limits, copying limits between users, and the reporting commands.
3. [Hitting the Limit & the Grace Period](./course-03-hitting-the-limit-and-grace-period.md): what happens at the hard limit, and the grace-period countdown at the soft limit.
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md): what you learned, your missions, questions to check yourself, and cleanup.

## Learning objectives

After this module you can:

- Enable quotas on an ext4 filesystem with the right mount options, `quotacheck`, and `quotaon`.
- Explain where the kernel actually enforces a quota — at write-syscall time against an in-kernel structure — and why `quotacheck` must run before the first `quotaon`.
- Set per-user and per-group block and inode limits with `setquota` (and `edquota`).
- Explain the difference between a soft limit, a hard limit, and the grace period, and trace the state transitions between under-soft, over-soft, and blocked.
- Set a group quota, copy limits with `edquota -p`, and read usage with `repquota` and `quota`.

## Before you start

You need to know the fields of an `/etc/fstab` line and to be comfortable with users, groups and `sudo`.

Your playground is one training spaceship: an Ubuntu 24.04 virtual machine with passwordless `sudo`. It has a 2 GB ext4 filesystem mounted at `/quota` (its `/etc/fstab` line already carries `usrquota,grpquota`, but quotas are **not on yet**), test users **alice** and **bob**, group **team**, and the `quota` toolset installed. Start the playground and connect to it with `astrona ssh section-080-module-02-playground`. Run every command in the parts in that shell.
