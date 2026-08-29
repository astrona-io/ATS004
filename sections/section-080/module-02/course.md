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

This module covers turning quotas on for an ext4 filesystem, setting per-user and per-group limits, the difference between soft and hard limits, and reading quota reports.

## Learning objectives

After this module you can:

- Enable quotas on an ext4 filesystem with the right mount options, `quotacheck`, and `quotaon`.
- Set per-user and per-group block and inode limits with `setquota` (and `edquota`).
- Explain the difference between a soft limit, a hard limit, and the grace period.
- Read quota usage with `repquota` and `quota`.

## Before you start

You need Section 015 (fstab mount options) and to be comfortable with users, groups, and `sudo`.

The linked playground gives you an Ubuntu server VM with a 2 GB ext4 filesystem mounted at `/quota` (its `/etc/fstab` line already carries `usrquota,grpquota`, but quotas are **not on yet**), test users **alice** and **bob**, group **team**, and the `quota` toolset installed. Run the command blocks below in that VM after `astrona ssh section-080-module-02-playground`.

## Turning quotas on

Three things must line up:

1. **Mount options.** The filesystem must be mounted with `usrquota` (per-user), `grpquota` (per-group), or both. On ext4 these go in the `/etc/fstab` options field; a running filesystem picks them up with `mount -o remount`.
2. **Quota accounting files.** `quotacheck` scans the filesystem and builds `aquota.user` / `aquota.group` at its root, recording current usage. Run it once, with the filesystem idle or read-only.
3. **Enforcement.** `quotaon` activates limit checking; `quotaoff` stops it. `quotaon -p` reports the current on/off state.

> [!TIP]
> **Try it — enable quotas on `/quota`**
>
> ```sh
> findmnt -no OPTIONS /quota
> sudo quotacheck -cugv /quota
> sudo quotaon -v /quota
> sudo quotaon -p /quota
> ```
>
> Expect something like:
>
> ```text
> rw,relatime,quota,usrquota,grpquota
>
> quotacheck: Scanning /dev/vdb [/quota] done
> quotacheck: Checked ... directories and ... files
>
> /dev/vdb [/quota]: user quotas turned on
> /dev/vdb [/quota]: group quotas turned on
>
> user quota on /quota (/dev/vdb) is on
> group quota on /quota (/dev/vdb) is on
> ```
>
> `findmnt` confirms `usrquota,grpquota` are active on the mount. `quotacheck -cugv` creates the accounting files (`-c` create, `-u` user, `-g` group, `-v` verbose); `quotaon` then switches on enforcement. On a systemd host the `quotaon.service` does this automatically at boot for fstab filesystems that have the options.

## Setting limits

A quota has **four numbers**, for two resources:

- **blocks** — disk space, counted in 1 KiB blocks (tools accept `40M`, `2G`, …).
- **inodes** — number of files/directories, regardless of their size.

For each, a **soft** and a **hard** limit:

- **hard** — an absolute ceiling. A write that would cross it fails immediately with "Disk quota exceeded".
- **soft** — may be exceeded temporarily. Once over it, a countdown (the **grace period**) starts; if the user is still over soft when grace expires, soft behaves like hard until they get back under it.

`setquota -u <user> <block-soft> <block-hard> <inode-soft> <inode-hard> <fs>` sets them non-interactively; `0` means "no limit". `edquota -u <user>` opens the same values in an editor.

> [!TIP]
> **Try it — give alice a 40M/50M space quota**
>
> ```sh
> sudo setquota -u alice 40M 50M 0 0 /quota
> sudo quota -u alice
> sudo repquota -s /quota
> ```
>
> Expect something like:
>
> ```text
> Disk quotas for user alice (uid 1001):
>   Filesystem  space  quota  limit  grace  files  quota  limit  grace
>       /quota     0K   40M    50M            0      0      0
>
> *** Report for user quotas on device /dev/vdb
>                    Block limits                File limits
> User      used   soft   hard  grace   used  soft  hard  grace
> alice      0K    40M    50M              0     0     0
> bob        0K     0K     0K               0     0     0
> ```
>
> alice has a 40 MiB soft / 50 MiB hard space limit and no inode limit (`0 0`). `repquota -s` shows every user's usage against their limits in human-readable units (`-s`).

## Hitting the limit

The hard limit stops a write mid-operation. The tool doing the writing gets an error; nothing is silently truncated beyond what fits.

> [!TIP]
> **Try it — write past the quota as alice**
>
> ```sh
> sudo -u alice dd if=/dev/zero of=/quota/alice/big bs=1M count=60
> sudo -u alice ls -lh /quota/alice/big
> sudo repquota -s /quota
> ```
>
> Expect something like:
>
> ```text
> dd: error writing '/quota/alice/big': Disk quota exceeded
> 49+0 records in
> 48+0 records out
>
> -rw-r--r-- 1 alice alice 49M ... /quota/alice/big
>
> User      used   soft   hard  grace
> alice     50M*   40M    50M   none
> ```
>
> `dd` wrote ~49 MiB, then hit the 50 MiB hard limit and failed. `repquota` marks alice's usage with `*` — over the soft limit — and the file stopped growing at the ceiling.

## The grace period

The grace period governs the soft limit. It is a per-filesystem setting (with a separate value for blocks and inodes), configured with `setquota -t <block-grace> <inode-grace> <fs>` in seconds. While a user is over soft but under hard, `repquota` shows a countdown; when it reaches zero, further writes are refused until they drop back under soft.

> [!TIP]
> **Try it — set and observe the grace period**
>
> ```sh
> sudo setquota -t 3600 3600 /quota
> sudo repquota -s /quota
> sudo setquota -u bob 10M 50M 0 0 /quota
> sudo -u bob dd if=/dev/zero of=/quota/bob/f bs=1M count=20
> sudo repquota -s /quota
> ```
>
> Expect something like:
>
> ```text
> User      used   soft   hard  grace
> bob       20M*   10M    50M   59min
> ```
>
> bob is 20 MiB used against a 10 MiB soft / 50 MiB hard limit — over soft, under hard, so writes still succeed but a `59min` grace countdown has started. If bob is still over 10 MiB when it hits zero, the soft limit starts behaving like a hard one.

> [!WARNING]
> **Common pitfalls**
>
> - **Mount options missing.** Without `usrquota`/`grpquota` on the mount, `quotaon` fails. Put them in `/etc/fstab` and `mount -o remount` (or reboot); check with `findmnt -no OPTIONS <mp>`.
> - **Skipping `quotacheck` the first time.** Enforcement needs the accounting files. Run `quotacheck -cug` once (filesystem idle) before the first `quotaon`.
> - **Quotas are per-filesystem.** A limit on `/quota` says nothing about `/home` or `/`. Each filesystem is quota-managed separately, and only if mounted with the options.
> - **Confusing soft and hard.** Soft can be exceeded until the grace period runs out; hard cannot be exceeded at all. Set hard as the true ceiling and soft a bit below as the warning line.
> - **Root is exempt.** Processes running as root ignore quotas. Test enforcement as a normal user (`sudo -u alice ...`).
> - **`edquota` shows blocks in KiB.** The `blocks`/`inodes` "used" columns in `edquota` are current usage in 1 KiB units and are informational — editing them does nothing. Change the `soft`/`hard` columns.
