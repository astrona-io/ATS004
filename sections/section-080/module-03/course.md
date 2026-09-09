# XFS Quotas and Project Quotas

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-080/module-03/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-080/module-03/playground
> astrona destroy section-080-module-03-playground
> ```

XFS has its own quota system, managed with a different tool and a different workflow from the ext4 quotas of the previous module. It also adds a third kind of limit: **project quotas**, which cap a *directory tree* regardless of who owns the files in it.

## How this module is organised

1. **[Part 1 — XFS Quotas & User Limits](./course-01-xfs-quotas-and-user-limits.md)** — why XFS needs no `quotacheck` (accounting is built into its own on-disk metadata, not bolted on), the mount options, and setting user block limits with `xfs_quota -x`.
2. **[Part 2 — Defining & Enforcing a Project Quota](./course-02-project-quotas.md)** — mapping a directory to a project ID in `/etc/projects`/`/etc/projid`, the one-time stamping pass and why it's the only scan XFS quotas ever need, and capping a tree regardless of ownership.

## Learning objectives

After this module you can:

- Enable XFS user and project quotas with the correct mount options and confirm with `xfs_quota state`.
- Explain why XFS needs no `quotacheck`, in terms of where its quota accounting actually lives on disk.
- Set and report user block limits with `xfs_quota` in expert mode.
- Define a project in `/etc/projects` and `/etc/projid` and initialise it with `xfs_quota project -s`, and explain what that pass does that never needs repeating.
- Apply a project quota to a directory tree and explain how it differs from user and group quotas.

## Before you start

You need the previous module: soft vs hard limits, blocks vs inodes, and the grace period. The concepts carry over; the commands do not.

The linked playground gives you an Ubuntu server VM with a 2 GB XFS filesystem mounted at `/srv/xfs` (its `/etc/fstab` line carries `uquota,pquota`, so quotas are already active), a directory `/srv/xfs/webdata`, and users **alice** and **bob**. Run the command blocks in Parts 1–2 in that VM after `astrona ssh section-080-module-03-playground`.
