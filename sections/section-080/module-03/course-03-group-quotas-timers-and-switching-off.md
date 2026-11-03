# Group Limits, Grace Timers & Switching Quotas Off

The same `xfs_quota` tool also handles groups, grace times and switching quotas off. This part shows these three jobs, because a real task often asks for them next to user and project limits.

## Group limits and single-account reports

A group limit has the same shape as a user limit, with `-g` before the name. The group quota needs `gquota` on the mount, so it works only where the filesystem was mounted with that option.

A fast way to see one account is the `quota` sub-command. It prints one user, group or project, without the full table.

<!-- astrona:playground:renew -->

### See it in your playground

Show alice's usage and the project's usage, one account at a time:

```sh
sudo xfs_quota -x -c 'quota -u -h alice' /srv/xfs
sudo xfs_quota -x -c 'quota -p -h webdata' /srv/xfs
```

Each command prints the usage and limits of one account. The project command needs the `webdata` project. If it does not exist yet, the command reports that the project is not known. To create it, add `42:/srv/xfs/webdata` to `/etc/projects`, add `webdata:42` to `/etc/projid`, and run `sudo xfs_quota -x -c 'project -s webdata' /srv/xfs`.

## Grace timers

The soft limit has a grace time, as on ext4. On XFS you set it with the `timer` sub-command. The option `-u` is for users, `-g` for groups and `-p` for projects. The option `-b` sets the block timer and `-i` the inode timer.

```sh
sudo xfs_quota -x -c 'timer -u -b 10m' /srv/xfs
sudo xfs_quota -x -c 'state' /srv/xfs
```

The `state` output lists the blocks grace time of each quota type. The default is seven days.

## Switching quotas off

The sub-command `off` stops enforcement and accounting for the type you name, for example `off -u`. The sub-command `remove` frees the space that the quota data used, and it works only after the quota is off. Both are expert-mode commands.

Be careful about the order. After `off`, you cannot switch the quota on again with `xfs_quota`. You must unmount and mount again with the option. Using `off` on a live system is a rare repair step. The normal way to stop limiting a user is to set their limits to `0`:

```sh
sudo xfs_quota -x -c 'limit bsoft=0 bhard=0 alice' /srv/xfs
sudo xfs_quota -x -c 'report -h' /srv/xfs
```

The report shows alice with no limit again.

## Common pitfalls

> [!WARNING]
> - **Using `off` to lift a limit.** It stops quota accounting for the whole type, and only a mount switches it on again. Set the limit to `0` instead.
> - **Setting a group limit without `gquota`.** The command has nothing to account against. Check the mount options with `findmnt -no OPTIONS <mount point>`.
> - **Forgetting the type letter in `timer`.** Without `-u`, `-g` or `-p`, the timer applies to users only.
> - **Mixing up `-b` and `-i`.** One sets the blocks timer and the other sets the inodes timer.

## Your mission: Copy User Quotas and Set XFS Group Limits Lab

You can now set group limits and a grace timer on XFS. The mission asks you to copy one user's limits to two other users on ext4 with `edquota -p alice bob carol`, then set block limits and a 3-day block timer for a group on XFS.

The mission runs on its own training ship. A playground cannot be paused, so remove it first to free memory. It always starts clean again:

```sh
astrona destroy section-080-module-03-playground
```

Then start the mission and connect to it:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-080/module-03/labs/lab-02
astrona ssh ats-004-lab-080-03-02
```

Read the task in [`question.md`](./labs/lab-02/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-080/module-03/labs/lab-02
```

When the mission is done, remove it and start a fresh playground:

```sh
astrona destroy ats-004-lab-080-03-02
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-080/module-03/playground
```
