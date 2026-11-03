# Group Quotas, Copying Limits & Reading Reports

A user quota caps one crew member. A group quota caps a whole rank, however the files are spread among its members. This part sets a group limit, copies a limit from one user to another, and reads the reports that tell you who is close to the wall.

## Group limits

The group quota counts every file whose group owner is the group, no matter which user wrote it. The command is `setquota -g <group> <block-soft> <block-hard> <inode-soft> <inode-hard> <filesystem>`. The kernel checks both limits on each write: the user's and the group's. The write fails if either one is over its hard limit.

<!-- astrona:playground:renew -->

### See it in your playground

Make sure quotas are on, give the group `team` an 80M soft and 100M hard limit, and read the group report:

```sh
sudo quotaon -p /quota
sudo setquota -g team 80M 100M 0 0 /quota
sudo repquota -g -s /quota
```

If the first command says quotas are off, run `sudo quotacheck -cugv /quota` and then `sudo quotaon -v /quota`. The report for groups lists `team` with 80M soft and 100M hard.

Now check the limit for the group, as a normal group member would see it:

```sh
sudo quota -g team
```

This prints the usage and limits of the group `team`.

## Copying limits and editing by hand

Setting the same numbers for ten users is slow. The command `edquota -p <prototype user> <user>...` copies the limits of one user to others:

```sh
sudo edquota -p alice bob
sudo repquota -s /quota
```

After this, bob has the same limits as alice. The command `edquota -u <user>` opens an editor on one user's limits. In that table, the `blocks` and `inodes` columns show current use and are only information. Change only the `soft` and `hard` columns.

## Reading reports

Three commands show quota data, and each one has a purpose:

- `quota -u <user>` and `quota -g <group>` show one account. A normal user may run `quota` for their own account.
- `repquota -s <filesystem>` shows all users. Add `-g` for groups, or `-a` for every quota filesystem.
- `quotaon -p <filesystem>` shows whether enforcement is on.

In `repquota`, a `+` or `-` pair in the flag column marks the block and inode state. A `+` means the soft limit is passed. This is how you spot users in trouble before they hit the wall.

## Common pitfalls

> [!WARNING]
> - **Setting only the user quota.** A group quota is separate. Both limits apply, and the stricter one stops the write first.
> - **Editing the `used` columns in `edquota`.** They are not stored values. The kernel derives usage from real data, so changes there do nothing.
> - **Copying limits with `edquota -p` and expecting a group copy.** Add `-g` to copy group limits to another group.
> - **Forgetting that files keep their old owner.** A file counts against the group that owns it. Moving a file into a directory does not change its group owner by itself.

## Your mission: ext4 User & Group Quotas Lab

You can now switch quotas on and set user and group limits. The mission asks you to build the accounting files, enforce quotas on `/quota`, and set limits for alice, bob and the group `team`.

The mission runs on its own training ship. A playground cannot be paused, so remove it first to free memory. It always starts clean again:

```sh
astrona destroy section-080-module-02-playground
```

Then start the mission and connect to it:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-080/module-02/labs/lab-01
astrona ssh ats-004-lab-083
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-080/module-02/labs/lab-01
```

When the mission is done, remove it and start a fresh playground:

```sh
astrona destroy ats-004-lab-083
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-080/module-02/playground
```
