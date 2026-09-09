# Part 1 — Turning Quotas On & Setting Limits

> Prerequisite: [Module landing page](./course.md). Next: [Part 2 — Hitting the Limit & the Grace Period](./course-02-hitting-the-limit-and-grace-period.md).

Before a limit means anything, three separate pieces have to line up: the mount has to opt in, the accounting has to be built, and enforcement has to be switched on. This part covers all three, then setting the actual numbers.

## Turning quotas on

Three things must line up:

1. **Mount options.** The filesystem must be mounted with `usrquota` (per-user), `grpquota` (per-group), or both. On ext4 these go in the `/etc/fstab` options field; a running filesystem picks them up with `mount -o remount`.
2. **Quota accounting files.** `quotacheck` scans the filesystem and builds `aquota.user` / `aquota.group` at its root, recording current usage. Run it once, with the filesystem idle or read-only.
3. **Enforcement.** `quotaon` activates limit checking; `quotaoff` stops it. `quotaon -p` reports the current on/off state.

The reason all three matter, and in this order, is where enforcement actually happens: the kernel checks a user's quota **at write-syscall time** — inside the filesystem's `write()` path, against a small in-kernel structure holding that user's current usage and limits — not via a periodic scan or a cron job. `aquota.user` / `aquota.group` are what seed that in-kernel structure at `quotaon` time and what it gets flushed back to; without `quotacheck` having built them first, there is nothing correct to load, which is why `quotaon` on a filesystem that skipped `quotacheck` either refuses or starts enforcing against stale, wrong numbers.

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
> `findmnt` confirms `usrquota,grpquota` are active on the mount. `quotacheck -cugv` creates the accounting files (`-c` create, `-u` user, `-g` group, `-v` verbose); `quotaon` then loads them into the kernel's per-user/per-group structures and switches on the write-time check. On a systemd host the `quotaon.service` does this automatically at boot for fstab filesystems that have the options.

## Setting limits

A quota has **four numbers**, for two resources:

- **blocks** — disk space, counted in 1 KiB blocks (tools accept `40M`, `2G`, …).
- **inodes** — number of files/directories, regardless of their size.

For each, a **soft** and a **hard** limit:

- **hard** — an absolute ceiling. A write that would cross it fails immediately with "Disk quota exceeded" — the write-syscall check from above rejecting the call outright.
- **soft** — may be exceeded temporarily. Once over it, a countdown (the **grace period**, Part 2) starts; if the user is still over soft when grace expires, soft behaves like hard until they get back under it.

`setquota -u <user> <block-soft> <block-hard> <inode-soft> <inode-hard> <fs>` sets them non-interactively; `0` means "no limit". `edquota -u <user>` opens the same values in an editor. Either way, `setquota`/`edquota` write straight into the same in-kernel structure `quotaon` loaded — there is no separate "apply" step.

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

> *`quotaon` loads accounting into the kernel; every write after that is checked in-line, against numbers `setquota` edits directly — no daemon polls this, no scan re-checks it later.*

## Reference

- `man quotacheck` — the `-c`/`-u`/`-g`/`-v` flags and when a re-run is needed (after `fsck` repairs, after restoring from backup).
- `man setquota` — the full argument order and the block/inode unit suffixes it accepts.
