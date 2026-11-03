# XFS Quotas and Project Quotas

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-080/module-03/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-080/module-03/playground
> astrona destroy section-080-module-03-playground
> ```

XFS has its own quota system, managed with its own tool and its own workflow, different from the `quotacheck` and `quotaon` steps used on ext4. It also adds a third kind of limit: **project quotas**, which cap a *directory tree* regardless of who owns the files in it.

## The parts of this module

1. [XFS Quotas & User Limits](./course-01-xfs-quotas-and-user-limits.md): why XFS needs no `quotacheck`, the mount options, and user limits with `xfs_quota -x`.
2. [Defining & Enforcing a Project Quota](./course-02-project-quotas.md): map a directory to a project number, stamp it once, and cap the tree.
3. [Group Limits, Grace Timers & Switching Quotas Off](./course-03-group-quotas-timers-and-switching-off.md): group limits, one-account reports, grace timers and `off`. A graded mission ends this part.
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md): what you learned, your mission, questions to check yourself, and cleanup.

## Learning objectives

After this module you can:

- Enable XFS user and project quotas with the correct mount options and confirm with `xfs_quota state`.
- Explain why XFS needs no `quotacheck`, in terms of where its quota accounting actually lives on disk.
- Set and report user block limits with `xfs_quota` in expert mode.
- Define a project in `/etc/projects` and `/etc/projid` and initialise it with `xfs_quota project -s`, and explain what that pass does that never needs repeating.
- Apply a project quota to a directory tree and explain how it differs from user and group quotas.
- Set group limits and grace timers with `xfs_quota`, and explain why `off` is not the way to lift a limit.

## Before you start

You should know what a soft limit, a hard limit and a grace period are, and the difference between blocks and inodes.

Your playground is one training spaceship: an Ubuntu 24.04 virtual machine with passwordless `sudo`. It has a 2 GB XFS filesystem mounted at `/srv/xfs` (its `/etc/fstab` line carries `uquota,pquota`, so quotas are already active), a directory `/srv/xfs/webdata`, and users **alice** and **bob**. Start the playground and connect to it with `astrona ssh section-080-module-03-playground`. Run every command in the parts in that shell.
