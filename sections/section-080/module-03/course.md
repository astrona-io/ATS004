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

This module covers turning on XFS quotas (just a mount option — no `quotacheck`), setting user limits with `xfs_quota`, and defining and enforcing a project quota on a directory.

## Learning objectives

After this module you can:

- Enable XFS user and project quotas with the correct mount options and confirm with `xfs_quota state`.
- Set and report user block limits with `xfs_quota` in expert mode.
- Define a project in `/etc/projects` and `/etc/projid` and initialise it with `xfs_quota project -s`.
- Apply a project quota to a directory tree and explain how it differs from user and group quotas.

## Before you start

You need the previous module: soft vs hard limits, blocks vs inodes, and the grace period. The concepts carry over; the commands do not.

The linked playground gives you an Ubuntu server VM with a 2 GB XFS filesystem mounted at `/srv/xfs` (its `/etc/fstab` line carries `uquota,pquota`, so quotas are already active), a directory `/srv/xfs/webdata`, and users **alice** and **bob**. Run the command blocks below in that VM after `astrona ssh section-080-module-03-playground`.

## XFS quotas are a mount option

XFS records quota usage in internal metadata, not in `aquota.*` files. There is **no `quotacheck`** and no separate `quotaon` for the normal case: quotas are enabled by mounting with the right option and are active from that moment.

- `uquota` / `usrquota` — user quotas, accounting **and** enforcement.
- `gquota` / `grpquota` — group quotas.
- `pquota` / `prjquota` — project quotas.
- `uqnoenforce` (and `gqnoenforce`, `pqnoenforce`) — account only, do not block writes. Useful for measuring before you set limits.

On most current kernels you can combine `uquota` with either `gquota` or `pquota`; group and project quotas historically shared the same on-disk field, so some setups cannot have both at once. The root filesystem is a special case — it needs the options passed on the kernel command line, not just fstab.

`xfs_quota` is the management tool. Plain mode is read-only; `-x` (expert mode) is required to change anything. `-c '<command>'` runs one sub-command.

> [!TIP]
> **Try it — check the quota state**
>
> ```sh
> findmnt -no OPTIONS /srv/xfs
> sudo xfs_quota -x -c 'state' /srv/xfs
> ```
>
> Expect something like:
>
> ```text
> rw,relatime,attr2,inode64,logbufs=8,logbsize=32k,usrquota,prjquota
>
> User quota state on /srv/xfs (/dev/vdb)
>   Accounting: ON
>   Enforcement: ON
> ...
> Project quota state on /srv/xfs (/dev/vdb)
>   Accounting: ON
>   Enforcement: ON
> ```
>
> `usrquota` and `prjquota` are on the mount, and `state` reports both accounting and enforcement `ON` — no `quotacheck` step was needed, unlike ext4.

## User limits

`xfs_quota -x -c 'limit bsoft=<n> bhard=<n> <user>' <fs>` sets a user's block limits (`isoft=`/`ihard=` for inode counts). `report` shows usage; `-h` for human units, `-u` for the user report (the default).

> [!TIP]
> **Try it — limit alice and exceed it**
>
> ```sh
> sudo xfs_quota -x -c 'limit bsoft=40m bhard=50m alice' /srv/xfs
> sudo xfs_quota -x -c 'report -h' /srv/xfs
> sudo -u alice dd if=/dev/zero of=/srv/xfs/alice-file bs=1M count=60
> sudo xfs_quota -x -c 'report -h' /srv/xfs
> ```
>
> Expect something like:
>
> ```text
> User quota on /srv/xfs (/dev/vdb)
>                         Blocks
> User        Used   Soft   Hard Warn/Grace
> alice          0     40M    50M  00 [------]
>
> dd: error writing '/srv/xfs/alice-file': Disk quota exceeded
> 49+0 records in
>
> alice         50M    40M    50M  00 [--------]
> ```
>
> alice's writes stop at the 50 MiB hard limit with the same "Disk quota exceeded" error as ext4. The mechanics (soft, hard, grace) are identical to the previous module; only the tool differs.

## Defining a project

A **project** is a numeric ID attached to a directory tree. Every file created anywhere under that tree inherits the project ID, and the project's quota caps the whole tree's usage — no matter which user or group owns each file. This is what you use for "the `/var/www/site` directory may use at most 10 GB".

Two files map the pieces:

- `/etc/projects` — `<id>:<path>` (the ID-to-directory mapping).
- `/etc/projid` — `<name>:<id>` (a friendly name for the ID).

Then `xfs_quota -x -c 'project -s <name>' <fs>` walks the tree and stamps the project ID onto existing files.

> [!TIP]
> **Try it — create the `webdata` project**
>
> ```sh
> echo '42:/srv/xfs/webdata' | sudo tee -a /etc/projects
> echo 'webdata:42' | sudo tee -a /etc/projid
> sudo xfs_quota -x -c 'project -s webdata' /srv/xfs
> sudo xfs_quota -x -c 'report -p -h' /srv/xfs
> ```
>
> Expect something like:
>
> ```text
> Setting up project webdata (path /srv/xfs/webdata)...
> Processed 1 (/etc/projects and cmdline) paths for project webdata
>
> Project quota on /srv/xfs (/dev/vdb)
>                         Blocks
> Project     Used   Soft   Hard Warn/Grace
> webdata        0      0      0  00 [------]
> ```
>
> The project now exists and `report -p` lists it, with no limit set yet. `project -s` also sets an inheritance flag on the directory, so new files under `/srv/xfs/webdata` automatically belong to project `42`.

## Enforcing a project quota

`xfs_quota -x -c 'limit -p bhard=<n> <name>' <fs>` sets the project's limit. From then on, the *combined* size of everything under the tree is capped — writes by any user fail once the tree hits the ceiling.

> [!TIP]
> **Try it — cap the directory regardless of who writes**
>
> ```sh
> sudo xfs_quota -x -c 'limit -p bhard=100m webdata' /srv/xfs
> sudo -u alice dd if=/dev/zero of=/srv/xfs/webdata/a bs=1M count=70
> sudo -u bob   dd if=/dev/zero of=/srv/xfs/webdata/b bs=1M count=70
> sudo xfs_quota -x -c 'report -p -h' /srv/xfs
> ```
>
> Expect something like:
>
> ```text
> (alice's dd succeeds — ~70M)
> dd: error writing '/srv/xfs/webdata/b': Disk quota exceeded
> 30+0 records in
>
> Project     Used   Soft   Hard Warn/Grace
> webdata      100M     0    100M  00 [--------]
> ```
>
> alice wrote ~70 MiB, then bob could only add ~30 MiB before the tree hit its 100 MiB project limit — even though bob has no personal quota. The limit is on the *directory*, not the users.

> [!WARNING]
> **Common pitfalls**
>
> - **Looking for `quotacheck` / `aquota.user`.** XFS has neither. Quotas are enabled by the mount option and stored in internal metadata; if the option is missing, remount with it (or reboot).
> - **Forgetting `-x`.** `xfs_quota` only changes limits in expert mode. Without `-x`, `limit` and `project` are unavailable.
> - **`pquota` and `gquota` together.** On some kernels they conflict (shared on-disk field). Pick the one you need; combine with `uquota`.
> - **Setting a project limit before `project -s`.** The directory must be initialised (which sets the inheritance flag and stamps existing files) before its quota means anything.
> - **Root filesystem quotas via fstab only.** For quotas on `/`, the options must be on the kernel command line; an fstab-only option is ignored there.
> - **Expecting ext4 `setquota`/`repquota` to work on XFS.** They do not. Use `xfs_quota` for XFS; the ext tools are for ext2/3/4.
