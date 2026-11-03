# Turning Quotas On & Setting Limits

Before a limit means anything, three separate pieces must line up: the mount has to opt in, the accounting has to be built, and enforcement has to be switched on. This part covers all three, and then sets the first user limits.

## Turning quotas on

Think of a quota as a cargo allowance for each crew member. The ship's core, the kernel, is the officer who checks the allowance, so the officer needs a list of what everyone already holds. Three things must be in place:

1. **Mount options.** The filesystem must be mounted with `usrquota` (per user), `grpquota` (per group) or both. On ext4 these go in the options field of `/etc/fstab`. A running filesystem picks them up with `mount -o remount`.
2. **Quota accounting files.** The command `quotacheck` scans the filesystem and builds `aquota.user` and `aquota.group` at its root. They record the current usage. Run it once, while the filesystem is idle.
3. **Enforcement.** The command `quotaon` activates the limit check, and `quotaoff` stops it. The command `quotaon -p` reports the on or off state.

The order matters because of where enforcement happens. The kernel checks a quota at write time, inside the filesystem's `write()` path, against a small structure in memory that holds the user's usage and limits. No scan and no cron job does this. The files `aquota.user` and `aquota.group` fill that structure when `quotaon` runs. If `quotacheck` never built them, there is nothing correct to load.

<!-- astrona:playground:renew -->

### See it in your playground

Check the mount options, build the accounting files, and switch enforcement on:

```sh
findmnt -no OPTIONS /quota
sudo quotacheck -cugv /quota
sudo quotaon -v /quota
sudo quotaon -p /quota
```

Expect something like this:

```text
rw,relatime,quota,usrquota,grpquota

quotacheck: Scanning /dev/vdb [/quota] done
quotacheck: Checked ... directories and ... files

/dev/vdb [/quota]: user quotas turned on
/dev/vdb [/quota]: group quotas turned on

user quota on /quota (/dev/vdb) is on
group quota on /quota (/dev/vdb) is on
```

The command `findmnt` shows that `usrquota,grpquota` are active on the mount. The command `quotacheck -cugv` creates the accounting files (`-c` create, `-u` user, `-g` group, `-v` verbose). The command `quotaon` loads them into the kernel and switches on the write-time check.

## Setting limits

A quota has two kinds of resource: **blocks** (disk space, counted in 1 KiB blocks, and tools accept `40M` or `2G`) and **inodes** (the number of files and directories, whatever their size). Each has a **soft** and a **hard** limit:

- The **hard** limit is a wall. A write that would cross it fails at once with "Disk quota exceeded".
- The **soft** limit is the warning line. A user may stay over it for a while, called the grace period. When the grace period ends and the user is still over, the soft limit acts like a hard one.

The command `setquota -u <user> <block-soft> <block-hard> <inode-soft> <inode-hard> <filesystem>` sets all four numbers without an editor. A `0` means no limit. The command `edquota -u <user>` opens the same values in an editor. Both write straight into the structure that `quotaon` loaded, so there is no separate apply step.

### See it in your playground

Give alice a 40M soft and 50M hard space quota, and read it back:

```sh
sudo setquota -u alice 40M 50M 0 0 /quota
sudo quota -u alice
sudo repquota -s /quota
```

Expect something like this:

```text
Disk quotas for user alice (uid 1001):
  Filesystem  space  quota  limit  grace  files  quota  limit  grace
      /quota     0K   40M    50M            0      0      0

*** Report for user quotas on device /dev/vdb
                   Block limits                File limits
User      used   soft   hard  grace   used  soft  hard  grace
alice      0K    40M    50M              0     0     0
bob        0K     0K     0K               0     0     0
```

Alice has a 40 MiB soft and 50 MiB hard space limit and no inode limit. The command `repquota -s` shows every user's usage against the limits, in human units.

## Common pitfalls

> [!WARNING]
> - **Mount options missing.** Without `usrquota` or `grpquota` on the mount, `quotaon` fails. Put them in `/etc/fstab`, remount, and check with `findmnt -no OPTIONS <mount point>`.
> - **Skipping `quotacheck` the first time.** `quotaon` has nothing correct to load. Run `quotacheck -cug` once, with the filesystem idle, before the first `quotaon`.
> - **Quotas are per filesystem.** A limit on `/quota` says nothing about `/home` or `/`.
> - **Root is exempt.** Processes that run as `root` skip the quota check. Test as a normal user, for example with `sudo -u alice`.
