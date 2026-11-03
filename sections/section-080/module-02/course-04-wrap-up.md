# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the missions in this module. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about cargo allowances on a shared ship: caps for each crew member and each rank, so that nobody fills the hold.

**From [Turning Quotas On & Setting Limits](./course-01-turning-on-and-setting-limits.md):**

- Three things must line up: mount options `usrquota` or `grpquota`, accounting files from `quotacheck`, and enforcement from `quotaon`.
- The kernel checks the quota at write time, against numbers loaded from the accounting files.
- `setquota -u <user> <soft> <hard> <isoft> <ihard> <filesystem>` sets limits. A `0` means no limit.

**From [Group Quotas, Copying Limits & Reading Reports](./course-02-group-quotas-and-reports.md):**

- `setquota -g` sets a group limit. The user limit and the group limit both apply.
- `edquota -p <prototype> <user>` copies limits. The `used` columns in `edquota` are not editable.
- `quota`, `repquota -s` and `quotaon -p` show usage, all users and enforcement state.

**From [Hitting the Limit & the Grace Period](./course-03-hitting-the-limit-and-grace-period.md):**

- A write that would pass the hard limit fails with "Disk quota exceeded".
- The grace period applies only to the soft limit. When it ends and the user is still over, soft acts as hard.
- `root` skips quotas, so test as a normal user.

## Your missions

You proved the skills in graded missions, right after the parts that taught them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [ext4 User & Group Quotas Lab](./labs/lab-01/README.md) | Group Quotas, Copying Limits & Reading Reports | enable quotas on `/quota` and set limits for two users and one group |
| [ext4 Quota Hard Limit & Grace Period Lab](./labs/lab-02/README.md) | Hitting the Limit & the Grace Period | cut a write off at the hard limit and capture a live grace countdown |

If you skipped one, go back to it now. They are short, and the exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. <code>quotaon</code> fails on a new filesystem. Which two things do you check?</summary>

Check that the mount has `usrquota` or `grpquota` (`findmnt -no OPTIONS <mount point>`), and that `quotacheck -cug` built the accounting files.
</details>

<details>
<summary>2. A user is over the soft limit and the grace period has ended. What happens to the next write?</summary>

It fails with "Disk quota exceeded", as if the soft limit were a hard limit.
</details>

<details>
<summary>3. Why does a <code>dd</code> test as <code>root</code> never hit the quota?</summary>

Processes that run as `root` skip the quota check. Test with `sudo -u <user>`.
</details>

<details>
<summary>4. How do you give bob the same limits as alice in one command?</summary>

`sudo edquota -p alice bob`.
</details>

<details>
<summary>5. A user is under their own hard limit, but the write still fails. What else can stop it?</summary>

The group quota of the file's group owner. Both limits apply, and either one can stop the write.
</details>

## Clean up the playground

Land your training ship before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-080-module-02-playground
```

If `astrona list` also showed the missions, remove them the same way:

```sh
astrona destroy ats-004-lab-083
astrona destroy ats-004-lab-085
```

Then check again:

```sh
astrona list
```

The list should no longer show the playground or the missions from this module. You can start the playground again at any time with the `astrona run` command from the end of a mission; it always starts clean, so nothing you broke carries over.
